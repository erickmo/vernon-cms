package main

import (
	"context"
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/go-chi/chi/v5"
	chimiddleware "github.com/go-chi/chi/v5/middleware"
	"github.com/redis/go-redis/v9"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"go.uber.org/fx"

	"github.com/erickmo/vernon-cms/infrastructure/cache"
	"github.com/erickmo/vernon-cms/infrastructure/config"
	"github.com/erickmo/vernon-cms/infrastructure/database"
	"github.com/erickmo/vernon-cms/infrastructure/telemetry"
	createcontent "github.com/erickmo/vernon-cms/internal/command/create_content"
	createcontentcategory "github.com/erickmo/vernon-cms/internal/command/create_content_category"
	createpage "github.com/erickmo/vernon-cms/internal/command/create_page"
	createsite "github.com/erickmo/vernon-cms/internal/command/create_site"
	createuser "github.com/erickmo/vernon-cms/internal/command/create_user"
	deletecontent "github.com/erickmo/vernon-cms/internal/command/delete_content"
	deletecontentcategory "github.com/erickmo/vernon-cms/internal/command/delete_content_category"
	deletepage "github.com/erickmo/vernon-cms/internal/command/delete_page"
	deletesite "github.com/erickmo/vernon-cms/internal/command/delete_site"
	deleteuser "github.com/erickmo/vernon-cms/internal/command/delete_user"
	addsitemember "github.com/erickmo/vernon-cms/internal/command/add_site_member"
	removesitemember "github.com/erickmo/vernon-cms/internal/command/remove_site_member"
	updatesitememberrole "github.com/erickmo/vernon-cms/internal/command/update_site_member_role"
	createdata "github.com/erickmo/vernon-cms/internal/command/create_data"
	createdatarecord "github.com/erickmo/vernon-cms/internal/command/create_data_record"
	deletedata "github.com/erickmo/vernon-cms/internal/command/delete_data"
	deletedatarecord "github.com/erickmo/vernon-cms/internal/command/delete_data_record"
	"github.com/erickmo/vernon-cms/internal/command/login"
	publishcontent "github.com/erickmo/vernon-cms/internal/command/publish_content"
	"github.com/erickmo/vernon-cms/internal/command/register"
	updatecontent "github.com/erickmo/vernon-cms/internal/command/update_content"
	updatecontentcategory "github.com/erickmo/vernon-cms/internal/command/update_content_category"
	updatedata "github.com/erickmo/vernon-cms/internal/command/update_data"
	updatedatarecord "github.com/erickmo/vernon-cms/internal/command/update_data_record"
	updatepage "github.com/erickmo/vernon-cms/internal/command/update_page"
	updatesite "github.com/erickmo/vernon-cms/internal/command/update_site"
	updateuser "github.com/erickmo/vernon-cms/internal/command/update_user"
	httpdelivery "github.com/erickmo/vernon-cms/internal/delivery/http"
	"github.com/erickmo/vernon-cms/internal/eventhandler"
	getcontent "github.com/erickmo/vernon-cms/internal/query/get_content"
	getcontentbyslug "github.com/erickmo/vernon-cms/internal/query/get_content_by_slug"
	getcontentcategory "github.com/erickmo/vernon-cms/internal/query/get_content_category"
	getdata "github.com/erickmo/vernon-cms/internal/query/get_data"
	getdatarecord "github.com/erickmo/vernon-cms/internal/query/get_data_record"
	getpage "github.com/erickmo/vernon-cms/internal/query/get_page"
	getsite "github.com/erickmo/vernon-cms/internal/query/get_site"
	getuser "github.com/erickmo/vernon-cms/internal/query/get_user"
	listcontent "github.com/erickmo/vernon-cms/internal/query/list_content"
	listcontentcategory "github.com/erickmo/vernon-cms/internal/query/list_content_category"
	listdata "github.com/erickmo/vernon-cms/internal/query/list_data"
	listdatarecord "github.com/erickmo/vernon-cms/internal/query/list_data_record"
	listdatarecordoptions "github.com/erickmo/vernon-cms/internal/query/list_data_record_options"
	listpage "github.com/erickmo/vernon-cms/internal/query/list_page"
	listsite "github.com/erickmo/vernon-cms/internal/query/list_site"
	listsitemember "github.com/erickmo/vernon-cms/internal/query/list_site_member"
	listuser "github.com/erickmo/vernon-cms/internal/query/list_user"
	"github.com/erickmo/vernon-cms/pkg/auth"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/eventbus"
	"github.com/erickmo/vernon-cms/pkg/hooks"
	"github.com/erickmo/vernon-cms/pkg/middleware"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

func main() {
	zerolog.TimeFieldFormat = zerolog.TimeFormatUnix

	app := fx.New(
		fx.Provide(
			config.Load,
			database.NewPostgresDB,
			cache.NewRedisClient,
			newEventBus,
			newMetrics,
			newJWTService,
			newCommandBus,
			newQueryBus,

			// Repositories (Write)
			database.NewPageRepository,
			database.NewContentCategoryRepository,
			database.NewContentRepository,
			database.NewUserRepository,
			database.NewDataRepository,
			database.NewSiteRepository,

			// Read Repositories (site-scoped wrappers)
			database.NewPageReadRepository,
			database.NewContentCategoryReadRepository,
			database.NewContentReadRepository,
			database.NewDataReadRepository,

			// HTTP Handlers
			newPageHandler,
			newContentCategoryHandler,
			newContentHandler,
			newUserHandler,
			newAuthHandler,
			newDataHandler,
			newSiteHandler,

			// Login handler (special — needs ReadRepository + SiteReadRepo + JWTService)
			newLoginHandler,

			// Event Handlers
			eventhandler.NewCDNCacheHandler,
		),
		fx.Invoke(
			registerCommandHandlers,
			registerQueryHandlers,
			registerEventHandlers,
			startServer,
		),
	)

	app.Run()
}

func newEventBus() eventbus.EventBus {
	return eventbus.NewInMemoryEventBus()
}

func newMetrics() (*telemetry.Metrics, error) {
	m, _, err := telemetry.InitMetrics()
	return m, err
}

func newJWTService(cfg *config.Config) *auth.JWTService {
	return auth.NewJWTService(cfg.JWT.Secret, cfg.JWT.AccessExpiry, cfg.JWT.RefreshExpiry)
}

func newCommandBus(metrics *telemetry.Metrics) *commandbus.CommandBus {
	bus := commandbus.New(metrics)
	bus.Use(&hooks.LoggingHook{})
	bus.Use(&hooks.ValidationHook{})
	return bus
}

func newQueryBus(metrics *telemetry.Metrics) *querybus.QueryBus {
	return querybus.New(metrics)
}

func newPageHandler(cmdBus *commandbus.CommandBus, queryBus *querybus.QueryBus) *httpdelivery.PageHandler {
	return httpdelivery.NewPageHandler(cmdBus, queryBus)
}

func newContentCategoryHandler(cmdBus *commandbus.CommandBus, queryBus *querybus.QueryBus) *httpdelivery.ContentCategoryHandler {
	return httpdelivery.NewContentCategoryHandler(cmdBus, queryBus)
}

func newContentHandler(cmdBus *commandbus.CommandBus, queryBus *querybus.QueryBus) *httpdelivery.ContentHandler {
	return httpdelivery.NewContentHandler(cmdBus, queryBus)
}

func newUserHandler(cmdBus *commandbus.CommandBus, queryBus *querybus.QueryBus) *httpdelivery.UserHandler {
	return httpdelivery.NewUserHandler(cmdBus, queryBus)
}

func newLoginHandler(userRepo *database.UserRepository, siteRepo *database.SiteRepository, jwtSvc *auth.JWTService) *login.Handler {
	return login.NewHandler(userRepo, siteRepo, jwtSvc)
}

func newAuthHandler(cmdBus *commandbus.CommandBus, loginHandler *login.Handler, jwtSvc *auth.JWTService) *httpdelivery.AuthHandler {
	return httpdelivery.NewAuthHandler(cmdBus, loginHandler, jwtSvc)
}

func newDataHandler(cmdBus *commandbus.CommandBus, queryBus *querybus.QueryBus) *httpdelivery.DataHandler {
	return httpdelivery.NewDataHandler(cmdBus, queryBus)
}

func newSiteHandler(cmdBus *commandbus.CommandBus, queryBus *querybus.QueryBus) *httpdelivery.SiteHandler {
	return httpdelivery.NewSiteHandler(cmdBus, queryBus)
}

func registerCommandHandlers(
	bus *commandbus.CommandBus,
	eb eventbus.EventBus,
	pageRepo *database.PageRepository,
	catRepo *database.ContentCategoryRepository,
	contentRepo *database.ContentRepository,
	userRepo *database.UserRepository,
	dataRepo *database.DataRepository,
	siteRepo *database.SiteRepository,
) {
	// Page commands
	bus.Register("CreatePage", createpage.NewHandler(pageRepo, eb))
	bus.Register("UpdatePage", updatepage.NewHandler(pageRepo, eb))
	bus.Register("DeletePage", deletepage.NewHandler(pageRepo, eb))

	// Content Category commands
	bus.Register("CreateContentCategory", createcontentcategory.NewHandler(catRepo, eb))
	bus.Register("UpdateContentCategory", updatecontentcategory.NewHandler(catRepo, eb))
	bus.Register("DeleteContentCategory", deletecontentcategory.NewHandler(catRepo, eb))

	// Content commands
	bus.Register("CreateContent", createcontent.NewHandler(contentRepo, eb))
	bus.Register("UpdateContent", updatecontent.NewHandler(contentRepo, eb))
	bus.Register("DeleteContent", deletecontent.NewHandler(contentRepo, eb))
	bus.Register("PublishContent", publishcontent.NewHandler(contentRepo, eb))

	// User commands
	bus.Register("CreateUser", createuser.NewHandler(userRepo, eb))
	bus.Register("UpdateUser", updateuser.NewHandler(userRepo, eb))
	bus.Register("DeleteUser", deleteuser.NewHandler(userRepo, eb))

	// Auth commands
	bus.Register("Register", register.NewHandler(userRepo, eb))

	// Data commands
	bus.Register("CreateData", createdata.NewHandler(dataRepo, eb))
	bus.Register("UpdateData", updatedata.NewHandler(dataRepo, eb))
	bus.Register("DeleteData", deletedata.NewHandler(dataRepo, eb))
	bus.Register("CreateDataRecord", createdatarecord.NewHandler(dataRepo, eb))
	bus.Register("UpdateDataRecord", updatedatarecord.NewHandler(dataRepo, eb))
	bus.Register("DeleteDataRecord", deletedatarecord.NewHandler(dataRepo, eb))

	// Site commands
	bus.Register("CreateSite", createsite.NewHandler(siteRepo, eb))
	bus.Register("UpdateSite", updatesite.NewHandler(siteRepo, eb))
	bus.Register("DeleteSite", deletesite.NewHandler(siteRepo, eb))
	bus.Register("AddSiteMember", addsitemember.NewHandler(siteRepo, eb))
	bus.Register("RemoveSiteMember", removesitemember.NewHandler(siteRepo, eb))
	bus.Register("UpdateSiteMemberRole", updatesitememberrole.NewHandler(siteRepo, eb))
}

func registerQueryHandlers(
	bus *querybus.QueryBus,
	redisClient *redis.Client,
	metrics *telemetry.Metrics,
	cfg *config.Config,
	pageReadRepo *database.PageReadRepository,
	catReadRepo *database.ContentCategoryReadRepository,
	contentReadRepo *database.ContentReadRepository,
	userRepo *database.UserRepository,
	dataReadRepo *database.DataReadRepository,
	siteRepo *database.SiteRepository,
) {
	ttl := time.Duration(cfg.Redis.TTLSeconds) * time.Second

	bus.Register("GetPage", getpage.NewHandler(pageReadRepo, redisClient, metrics, ttl))
	bus.Register("ListPage", listpage.NewHandler(pageReadRepo))
	bus.Register("GetContentCategory", getcontentcategory.NewHandler(catReadRepo, redisClient, metrics, ttl))
	bus.Register("ListContentCategory", listcontentcategory.NewHandler(catReadRepo))
	bus.Register("GetContent", getcontent.NewHandler(contentReadRepo, redisClient, metrics, ttl))
	bus.Register("GetContentBySlug", getcontentbyslug.NewHandler(contentReadRepo, redisClient, metrics, ttl))
	bus.Register("ListContent", listcontent.NewHandler(contentReadRepo))
	bus.Register("GetUser", getuser.NewHandler(userRepo, redisClient, metrics, ttl))
	bus.Register("ListUser", listuser.NewHandler(userRepo))

	// Data queries
	bus.Register("ListData", listdata.NewHandler(dataReadRepo))
	bus.Register("GetData", getdata.NewHandler(dataReadRepo))
	bus.Register("ListDataRecord", listdatarecord.NewHandler(dataReadRepo))
	bus.Register("GetDataRecord", getdatarecord.NewHandler(dataReadRepo))
	bus.Register("ListDataRecordOptions", listdatarecordoptions.NewHandler(dataReadRepo))

	// Site queries
	bus.Register("GetSite", getsite.NewHandler(siteRepo))
	bus.Register("ListSite", listsite.NewHandler(siteRepo))
	bus.Register("ListSiteMember", listsitemember.NewHandler(siteRepo))
}

func registerEventHandlers(eb eventbus.EventBus, cdnHandler *eventhandler.CDNCacheHandler) {
	eb.Subscribe("page.created", cdnHandler.HandlePageEvent)
	eb.Subscribe("page.updated", cdnHandler.HandlePageEvent)
	eb.Subscribe("page.deleted", cdnHandler.HandlePageEvent)
	eb.Subscribe("content_category.created", cdnHandler.HandleContentCategoryEvent)
	eb.Subscribe("content_category.updated", cdnHandler.HandleContentCategoryEvent)
	eb.Subscribe("content_category.deleted", cdnHandler.HandleContentCategoryEvent)
	eb.Subscribe("content.created", cdnHandler.HandleContentEvent)
	eb.Subscribe("content.updated", cdnHandler.HandleContentEvent)
	eb.Subscribe("content.published", cdnHandler.HandleContentEvent)
	eb.Subscribe("content.deleted", cdnHandler.HandleContentEvent)
	eb.Subscribe("user.created", cdnHandler.HandleUserEvent)
	eb.Subscribe("user.updated", cdnHandler.HandleUserEvent)
	eb.Subscribe("user.deleted", cdnHandler.HandleUserEvent)

	// Data events
	eb.Subscribe("data.created", cdnHandler.HandleContentEvent)
	eb.Subscribe("data.updated", cdnHandler.HandleContentEvent)
	eb.Subscribe("data.deleted", cdnHandler.HandleContentEvent)
	eb.Subscribe("data_record.created", cdnHandler.HandleContentEvent)
	eb.Subscribe("data_record.updated", cdnHandler.HandleContentEvent)
	eb.Subscribe("data_record.deleted", cdnHandler.HandleContentEvent)
}

func corsWithOrigins(allowedOrigins string) func(http.Handler) http.Handler {
	origins := strings.Split(allowedOrigins, ",")
	originSet := make(map[string]bool, len(origins))
	for _, o := range origins {
		originSet[strings.TrimSpace(o)] = true
	}

	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			origin := r.Header.Get("Origin")
			if originSet[origin] || originSet["*"] {
				w.Header().Set("Access-Control-Allow-Origin", origin)
			}
			w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
			w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Site-ID")
			w.Header().Set("Access-Control-Allow-Credentials", "true")

			if r.Method == http.MethodOptions {
				w.WriteHeader(http.StatusNoContent)
				return
			}
			next.ServeHTTP(w, r)
		})
	}
}

func startServer(
	lc fx.Lifecycle,
	cfg *config.Config,
	jwtSvc *auth.JWTService,
	metrics *telemetry.Metrics,
	siteRepo *database.SiteRepository,
	authHandler *httpdelivery.AuthHandler,
	pageHandler *httpdelivery.PageHandler,
	catHandler *httpdelivery.ContentCategoryHandler,
	contentHandler *httpdelivery.ContentHandler,
	userHandler *httpdelivery.UserHandler,
	dataHandler *httpdelivery.DataHandler,
	siteHandler *httpdelivery.SiteHandler,
) {
	r := chi.NewRouter()

	// Global middleware
	r.Use(chimiddleware.RequestID)
	r.Use(middleware.Recovery)
	r.Use(corsWithOrigins(cfg.App.CORSOrigins))
	r.Use(middleware.Tracing)
	r.Use(middleware.Logging)
	r.Use(middleware.Metrics(metrics))
	r.Use(middleware.MaxBodySize(1 << 20)) // 1MB

	// Health check (public)
	r.Get("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"status":"ok"}`))
	})

	// Auth routes (public — no auth middleware, but include TenantResolution for login)
	r.Group(func(r chi.Router) {
		r.Use(middleware.TenantResolution(siteRepo))
		authHandler.RegisterRoutes(r)
	})

	// Tenant-scoped content routes
	r.Group(func(r chi.Router) {
		r.Use(middleware.TenantResolution(siteRepo))
		r.Use(middleware.Auth(jwtSvc))
		r.Use(middleware.RequireTenant())

		// Pages
		r.Route("/api/v1/pages", func(r chi.Router) {
			r.Get("/", pageHandler.List)
			r.Get("/{id}", pageHandler.GetByID)
			r.Group(func(r chi.Router) {
				r.Use(middleware.RequireSiteRole("admin", "editor"))
				r.Post("/", pageHandler.Create)
				r.Put("/{id}", pageHandler.Update)
			})
			r.Group(func(r chi.Router) {
				r.Use(middleware.RequireSiteRole("admin"))
				r.Delete("/{id}", pageHandler.Delete)
			})
		})

		// Content Categories
		r.Route("/api/v1/content-categories", func(r chi.Router) {
			r.Get("/", catHandler.List)
			r.Get("/{id}", catHandler.GetByID)
			r.Group(func(r chi.Router) {
				r.Use(middleware.RequireSiteRole("admin", "editor"))
				r.Post("/", catHandler.Create)
				r.Put("/{id}", catHandler.Update)
			})
			r.Group(func(r chi.Router) {
				r.Use(middleware.RequireSiteRole("admin"))
				r.Delete("/{id}", catHandler.Delete)
			})
		})

		// Contents
		r.Route("/api/v1/contents", func(r chi.Router) {
			r.Get("/", contentHandler.List)
			r.Get("/{id}", contentHandler.GetByID)
			r.Get("/slug/{slug}", contentHandler.GetBySlug)
			r.Group(func(r chi.Router) {
				r.Use(middleware.RequireSiteRole("admin", "editor"))
				r.Post("/", contentHandler.Create)
				r.Put("/{id}", contentHandler.Update)
				r.Put("/{id}/publish", contentHandler.Publish)
			})
			r.Group(func(r chi.Router) {
				r.Use(middleware.RequireSiteRole("admin"))
				r.Delete("/{id}", contentHandler.Delete)
			})
		})

		// Data
		r.Route("/api/v1/data", func(r chi.Router) {
			r.Get("/", dataHandler.ListDataTypes)
			r.Get("/{id}", dataHandler.GetDataType)
			r.Group(func(r chi.Router) {
				r.Use(middleware.RequireSiteRole("admin"))
				r.Post("/", dataHandler.CreateDataType)
				r.Put("/{id}", dataHandler.UpdateDataType)
				r.Delete("/{id}", dataHandler.DeleteDataType)
			})

			// Data Records
			r.Route("/{data_slug}/records", func(r chi.Router) {
				r.Get("/", dataHandler.ListRecords)
				r.Get("/options", dataHandler.ListRecordOptions)
				r.Get("/{id}", dataHandler.GetRecord)
				r.Group(func(r chi.Router) {
					r.Use(middleware.RequireSiteRole("admin", "editor"))
					r.Post("/", dataHandler.CreateRecord)
					r.Put("/{id}", dataHandler.UpdateRecord)
				})
				r.Group(func(r chi.Router) {
					r.Use(middleware.RequireSiteRole("admin"))
					r.Delete("/{id}", dataHandler.DeleteRecord)
				})
			})
		})
	})

	// Platform routes (no TenantResolution required)
	r.Group(func(r chi.Router) {
		r.Use(middleware.Auth(jwtSvc))

		// Users — admin only (global role)
		r.Route("/api/v1/users", func(r chi.Router) {
			r.Use(middleware.RequireRole("admin"))
			r.Post("/", userHandler.Create)
			r.Get("/", userHandler.List)
			r.Get("/{id}", userHandler.GetByID)
			r.Put("/{id}", userHandler.Update)
			r.Delete("/{id}", userHandler.Delete)
		})

		// Sites
		r.Route("/api/v1/sites", func(r chi.Router) {
			r.Post("/", siteHandler.Create)
			r.Get("/", siteHandler.ListMySites)
			r.Get("/{id}", siteHandler.GetByID)
			r.Put("/{id}", siteHandler.Update)
			r.Delete("/{id}", siteHandler.Delete)
			r.Route("/{id}/members", func(r chi.Router) {
				r.Get("/", siteHandler.ListMembers)
				r.Post("/", siteHandler.AddMember)
				r.Put("/{userID}/role", siteHandler.UpdateMemberRole)
				r.Delete("/{userID}", siteHandler.RemoveMember)
			})
		})
	})

	server := &http.Server{
		Addr:         ":" + cfg.HTTP.Port,
		Handler:      r,
		ReadTimeout:  cfg.HTTP.ReadTimeout,
		WriteTimeout: cfg.HTTP.WriteTimeout,
	}

	lc.Append(fx.Hook{
		OnStart: func(ctx context.Context) error {
			go func() {
				log.Info().Str("port", cfg.HTTP.Port).Msg("starting HTTP server")
				if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
					log.Fatal().Err(err).Msg("server failed")
				}
			}()
			fmt.Printf("\n  Vernon CMS is running on http://localhost:%s\n\n", cfg.HTTP.Port)
			return nil
		},
		OnStop: func(ctx context.Context) error {
			log.Info().Msg("shutting down HTTP server")
			return server.Shutdown(ctx)
		},
	})
}

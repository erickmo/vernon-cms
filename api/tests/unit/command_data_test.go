package unit

import (
	"context"
	"encoding/json"
	"fmt"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	createdata "github.com/erickmo/vernon-cms/internal/command/create_data"
	createdatarecord "github.com/erickmo/vernon-cms/internal/command/create_data_record"
	deletedata "github.com/erickmo/vernon-cms/internal/command/delete_data"
	deletedatarecord "github.com/erickmo/vernon-cms/internal/command/delete_data_record"
	updatedata "github.com/erickmo/vernon-cms/internal/command/update_data"
	updatedatarecord "github.com/erickmo/vernon-cms/internal/command/update_data_record"
	"github.com/erickmo/vernon-cms/tests/mocks"
)

func TestCreateDataHandler(t *testing.T) {
	t.Log("=== Scenario: CreateData Command Handler ===")
	t.Log("Goal: Verify data type creation with optional fields")

	repo := mocks.NewMockDataRepository()
	eb := mocks.NewMockEventBus()
	handler := createdata.NewHandler(repo, eb)
	ctx := context.Background()

	t.Run("success - data type without fields", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		cmd := createdata.Command{
			Name:       "Article",
			Slug:       "article",
			PluralName: "Articles",
		}
		err := handler.Handle(ctx, cmd)

		require.NoError(t, err)
		assert.Equal(t, 1, eb.EventCount())
		assert.Equal(t, "data.created", eb.LastEvent().EventName())
		t.Log("Result: DataType created, event published")
		t.Log("Status: PASSED")
	})

	t.Run("success - data type with fields", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		cmd := createdata.Command{
			Name:       "Product",
			Slug:       "product",
			PluralName: "Products",
			Fields: []createdata.FieldInput{
				{Name: "name", Label: "Name", FieldType: "text", IsRequired: true, SortOrder: 1},
				{Name: "price", Label: "Price", FieldType: "number", IsRequired: true, SortOrder: 2},
			},
		}
		err := handler.Handle(ctx, cmd)

		require.NoError(t, err)
		assert.Equal(t, "data.created", eb.LastEvent().EventName())
		t.Log("Result: DataType with 2 fields created")
		t.Log("Status: PASSED")
	})

	t.Run("success - with description and icon", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		desc := "Berita terkini"
		icon := "📰"
		cmd := createdata.Command{
			Name:        "News",
			Slug:        "news",
			PluralName:  "News Items",
			Description: &desc,
			Icon:        &icon,
		}
		err := handler.Handle(ctx, cmd)

		require.NoError(t, err)
		assert.Equal(t, 1, eb.EventCount())
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty name", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		cmd := createdata.Command{Slug: "slug", PluralName: "Plural"}
		err := handler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Equal(t, 0, eb.EventCount())
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty slug", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		cmd := createdata.Command{Name: "Name", PluralName: "Plural"}
		err := handler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Equal(t, 0, eb.EventCount())
		t.Log("Status: PASSED")
	})

	t.Run("fail - duplicate slug", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		_ = handler.Handle(ctx, createdata.Command{Name: "Tag", Slug: "tag", PluralName: "Tags"})
		eb.Reset()

		err := handler.Handle(ctx, createdata.Command{Name: "Tag 2", Slug: "tag", PluralName: "Tags 2"})
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "duplicate")
		t.Log("Result: Duplicate slug rejected")
		t.Log("Status: PASSED")
	})

	t.Run("fail - invalid field type", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		cmd := createdata.Command{
			Name:       "X",
			Slug:       "x",
			PluralName: "Xs",
			Fields: []createdata.FieldInput{
				{Name: "f", Label: "F", FieldType: "unsupported"},
			},
		}
		err := handler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "invalid field type")
		t.Log("Status: PASSED")
	})

	t.Run("fail - repo save error", func(t *testing.T) {
		repo.Reset()
		eb.Reset()
		repo.SaveDataTypeErr = fmt.Errorf("db down")

		cmd := createdata.Command{Name: "X", Slug: "x", PluralName: "Xs"}
		err := handler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Equal(t, 0, eb.EventCount())
		t.Log("Status: PASSED")
	})
}

func TestUpdateDataHandler(t *testing.T) {
	t.Log("=== Scenario: UpdateData Command Handler ===")
	t.Log("Goal: Verify data type update and field replacement")

	repo := mocks.NewMockDataRepository()
	eb := mocks.NewMockEventBus()
	createHandler := createdata.NewHandler(repo, eb)
	updateHandler := updatedata.NewHandler(repo, eb)
	ctx := context.Background()

	t.Run("success - updates data type metadata", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		_ = createHandler.Handle(ctx, createdata.Command{Name: "Old", Slug: "old-slug", PluralName: "Olds"})

		dataTypes, _, _ := repo.FindAllDataTypes(uuid.UUID{}, 0, 10)
		dataTypeID := dataTypes[0].ID
		eb.Reset()

		cmd := updatedata.Command{
			ID:         dataTypeID,
			Name:       "New Name",
			Slug:       "new-slug",
			PluralName: "New Names",
		}
		err := updateHandler.Handle(ctx, cmd)

		require.NoError(t, err)
		assert.Equal(t, "data.updated", eb.LastEvent().EventName())

		updated, _ := repo.FindDataTypeByID(dataTypeID, uuid.UUID{})
		assert.Equal(t, "New Name", updated.Name)
		assert.Equal(t, "new-slug", updated.Slug)
		t.Log("Result: DataType metadata updated and event published")
		t.Log("Status: PASSED")
	})

	t.Run("success - replaces fields", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		_ = createHandler.Handle(ctx, createdata.Command{
			Name:       "Blog",
			Slug:       "blog",
			PluralName: "Blogs",
			Fields: []createdata.FieldInput{
				{Name: "title", Label: "Title", FieldType: "text", IsRequired: true, SortOrder: 1},
			},
		})
		dataTypes, _, _ := repo.FindAllDataTypes(uuid.UUID{}, 0, 10)
		dataTypeID := dataTypes[0].ID
		eb.Reset()

		cmd := updatedata.Command{
			ID:         dataTypeID,
			Name:       "Blog",
			Slug:       "blog",
			PluralName: "Blogs",
			Fields: []updatedata.FieldInput{
				{Name: "title", Label: "Title", FieldType: "text", IsRequired: true, SortOrder: 1},
				{Name: "body", Label: "Body", FieldType: "rich_text", SortOrder: 2},
			},
		}
		err := updateHandler.Handle(ctx, cmd)

		require.NoError(t, err)
		fields, _ := repo.FindFieldsByDataTypeID(dataTypeID)
		assert.Len(t, fields, 2)
		t.Log("Result: Fields replaced (1 → 2 fields)")
		t.Log("Status: PASSED")
	})

	t.Run("fail - data type not found", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		cmd := updatedata.Command{
			ID: uuid.New(), Name: "X", Slug: "x", PluralName: "Xs",
		}
		err := updateHandler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "not found")
		t.Log("Status: PASSED")
	})
}

func TestDeleteDataHandler(t *testing.T) {
	t.Log("=== Scenario: DeleteData Command Handler ===")

	repo := mocks.NewMockDataRepository()
	eb := mocks.NewMockEventBus()
	createHandler := createdata.NewHandler(repo, eb)
	deleteHandler := deletedata.NewHandler(repo, eb)
	ctx := context.Background()

	t.Run("success - deletes data type", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		_ = createHandler.Handle(ctx, createdata.Command{Name: "Tag", Slug: "tag", PluralName: "Tags"})
		dataTypes, _, _ := repo.FindAllDataTypes(uuid.UUID{}, 0, 10)
		dataTypeID := dataTypes[0].ID
		eb.Reset()

		err := deleteHandler.Handle(ctx, deletedata.Command{ID: dataTypeID})

		require.NoError(t, err)
		assert.Equal(t, "data.deleted", eb.LastEvent().EventName())

		_, err = repo.FindDataTypeByID(dataTypeID, uuid.UUID{})
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "not found")
		t.Log("Status: PASSED")
	})

	t.Run("fail - data type not found", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		err := deleteHandler.Handle(ctx, deletedata.Command{ID: uuid.New()})

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "not found")
		t.Log("Status: PASSED")
	})
}

func TestCreateDataRecordHandler(t *testing.T) {
	t.Log("=== Scenario: CreateDataRecord Command Handler ===")
	t.Log("Goal: Verify record creation under a data type")

	repo := mocks.NewMockDataRepository()
	eb := mocks.NewMockEventBus()
	createDataHandler := createdata.NewHandler(repo, eb)
	createRecordHandler := createdatarecord.NewHandler(repo, eb)
	ctx := context.Background()

	t.Run("success - creates record", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		_ = createDataHandler.Handle(ctx, createdata.Command{Name: "Product", Slug: "product", PluralName: "Products"})
		eb.Reset()

		d, _ := json.Marshal(map[string]interface{}{"name": "Laptop", "price": 15000000})
		cmd := createdatarecord.Command{DataSlug: "product", Data: d}
		err := createRecordHandler.Handle(ctx, cmd)

		require.NoError(t, err)
		assert.Equal(t, "data_record.created", eb.LastEvent().EventName())
		t.Log("Status: PASSED")
	})

	t.Run("fail - data type not found", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		d, _ := json.Marshal(map[string]interface{}{"name": "test"})
		cmd := createdatarecord.Command{DataSlug: "nonexistent", Data: d}
		err := createRecordHandler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "not found")
		t.Log("Status: PASSED")
	})

	t.Run("fail - repo save record error", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		_ = createDataHandler.Handle(ctx, createdata.Command{Name: "Item", Slug: "item", PluralName: "Items"})
		repo.SaveRecordErr = fmt.Errorf("storage full")
		eb.Reset()

		d, _ := json.Marshal(map[string]interface{}{"name": "test"})
		cmd := createdatarecord.Command{DataSlug: "item", Data: d}
		err := createRecordHandler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "storage full")
		assert.Equal(t, 0, eb.EventCount())
		t.Log("Status: PASSED")
	})
}

func TestUpdateDataRecordHandler(t *testing.T) {
	t.Log("=== Scenario: UpdateDataRecord Command Handler ===")

	repo := mocks.NewMockDataRepository()
	eb := mocks.NewMockEventBus()
	createDataHandler := createdata.NewHandler(repo, eb)
	createRecordHandler := createdatarecord.NewHandler(repo, eb)
	updateRecordHandler := updatedatarecord.NewHandler(repo, eb)
	ctx := context.Background()

	t.Run("success - updates record data", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		_ = createDataHandler.Handle(ctx, createdata.Command{Name: "Product", Slug: "product", PluralName: "Products"})
		d, _ := json.Marshal(map[string]interface{}{"name": "Old Product"})
		_ = createRecordHandler.Handle(ctx, createdatarecord.Command{DataSlug: "product", Data: d})

		records, _, _ := repo.FindRecordsByDataSlug("product", uuid.UUID{}, "", 0, 10)
		recordID := records[0].ID
		eb.Reset()

		newData, _ := json.Marshal(map[string]interface{}{"name": "New Product"})
		cmd := updatedatarecord.Command{ID: recordID, DataSlug: "product", Data: newData}
		err := updateRecordHandler.Handle(ctx, cmd)

		require.NoError(t, err)
		assert.Equal(t, "data_record.updated", eb.LastEvent().EventName())
		t.Log("Status: PASSED")
	})

	t.Run("fail - record not found", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		d, _ := json.Marshal(map[string]interface{}{"name": "x"})
		cmd := updatedatarecord.Command{ID: uuid.New(), DataSlug: "product", Data: d}
		err := updateRecordHandler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "not found")
		t.Log("Status: PASSED")
	})
}

func TestDeleteDataRecordHandler(t *testing.T) {
	t.Log("=== Scenario: DeleteDataRecord Command Handler ===")

	repo := mocks.NewMockDataRepository()
	eb := mocks.NewMockEventBus()
	createDataHandler := createdata.NewHandler(repo, eb)
	createRecordHandler := createdatarecord.NewHandler(repo, eb)
	deleteRecordHandler := deletedatarecord.NewHandler(repo, eb)
	ctx := context.Background()

	t.Run("success - deletes record", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		_ = createDataHandler.Handle(ctx, createdata.Command{Name: "Post", Slug: "post", PluralName: "Posts"})
		d, _ := json.Marshal(map[string]interface{}{"title": "Test"})
		_ = createRecordHandler.Handle(ctx, createdatarecord.Command{DataSlug: "post", Data: d})

		records, _, _ := repo.FindRecordsByDataSlug("post", uuid.UUID{}, "", 0, 10)
		recordID := records[0].ID
		eb.Reset()

		cmd := deletedatarecord.Command{ID: recordID, DataSlug: "post"}
		err := deleteRecordHandler.Handle(ctx, cmd)

		require.NoError(t, err)
		assert.Equal(t, "data_record.deleted", eb.LastEvent().EventName())

		_, err = repo.FindRecordByID(recordID, uuid.UUID{})
		assert.Error(t, err)
		t.Log("Status: PASSED")
	})

	t.Run("fail - record not found", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		cmd := deletedatarecord.Command{ID: uuid.New(), DataSlug: "post"}
		err := deleteRecordHandler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "not found")
		t.Log("Status: PASSED")
	})
}

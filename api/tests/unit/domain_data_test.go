package unit

import (
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	data "github.com/erickmo/vernon-cms/internal/domain/data"
)

func TestNewDataType(t *testing.T) {
	t.Log("=== Scenario: DataType Entity Creation ===")
	t.Log("Goal: Verify factory validates input and creates data type with correct defaults")

	t.Run("success - valid input", func(t *testing.T) {
		d, err := data.NewDataType(uuid.UUID{}, "Article", "article", "Articles", "content", 1, nil, nil)

		require.NoError(t, err)
		assert.NotEmpty(t, d.ID)
		assert.Equal(t, "Article", d.Name)
		assert.Equal(t, "article", d.Slug)
		assert.Equal(t, "Articles", d.PluralName)
		assert.Equal(t, "content", d.SidebarSection)
		assert.Equal(t, 1, d.SidebarOrder)
		assert.Empty(t, d.Fields)
		assert.NotZero(t, d.CreatedAt)
		t.Log("Result: DataType created with expected defaults")
		t.Log("Status: PASSED")
	})

	t.Run("success - with description and icon", func(t *testing.T) {
		desc := "Artikel berita"
		icon := "📰"
		d, err := data.NewDataType(uuid.UUID{}, "News", "news", "News Items", "content", 2, &desc, &icon)

		require.NoError(t, err)
		assert.Equal(t, &desc, d.Description)
		assert.Equal(t, &icon, d.Icon)
		t.Log("Status: PASSED")
	})

	t.Run("success - empty sidebar_section defaults to content", func(t *testing.T) {
		d, err := data.NewDataType(uuid.UUID{}, "Tag", "tag", "Tags", "", 0, nil, nil)

		require.NoError(t, err)
		assert.Equal(t, "content", d.SidebarSection)
		t.Log("Result: Empty sidebar_section defaulted to 'content'")
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty name", func(t *testing.T) {
		d, err := data.NewDataType(uuid.UUID{}, "", "slug", "Plural", "content", 1, nil, nil)

		assert.Nil(t, d)
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "name")
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty slug", func(t *testing.T) {
		d, err := data.NewDataType(uuid.UUID{}, "Name", "", "Plural", "content", 1, nil, nil)

		assert.Nil(t, d)
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "slug")
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty plural_name", func(t *testing.T) {
		d, err := data.NewDataType(uuid.UUID{}, "Name", "slug", "", "content", 1, nil, nil)

		assert.Nil(t, d)
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "plural_name")
		t.Log("Status: PASSED")
	})
}

func TestNewDataField(t *testing.T) {
	t.Log("=== Scenario: DataField Factory ===")
	t.Log("Goal: Verify field factory validates type and required fields")

	d, _ := data.NewDataType(uuid.UUID{}, "Article", "article", "Articles", "content", 1, nil, nil)

	t.Run("success - text field", func(t *testing.T) {
		f, err := data.NewDataField(d.ID, "title", "Title", data.FieldTypeText, true, 1)

		require.NoError(t, err)
		assert.NotEmpty(t, f.ID)
		assert.Equal(t, d.ID, f.DataTypeID)
		assert.Equal(t, "title", f.Name)
		assert.Equal(t, "Title", f.Label)
		assert.Equal(t, data.FieldTypeText, f.FieldType)
		assert.True(t, f.IsRequired)
		assert.Equal(t, 1, f.SortOrder)
		t.Log("Status: PASSED")
	})

	t.Run("success - all valid field types", func(t *testing.T) {
		types := []data.FieldType{
			data.FieldTypeText,
			data.FieldTypeTextarea,
			data.FieldTypeNumber,
			data.FieldTypeEmail,
			data.FieldTypeURL,
			data.FieldTypePhone,
			data.FieldTypeDate,
			data.FieldTypeSelect,
			data.FieldTypeCheckbox,
			data.FieldTypeImageURL,
			data.FieldTypeRichText,
			data.FieldTypeRelation,
		}
		for _, ft := range types {
			f, err := data.NewDataField(d.ID, "field", "Field", ft, false, 0)
			require.NoError(t, err)
			assert.Equal(t, ft, f.FieldType)
		}
		t.Log("Result: All 12 field types accepted")
		t.Log("Status: PASSED")
	})

	t.Run("fail - invalid field type", func(t *testing.T) {
		f, err := data.NewDataField(d.ID, "field", "Field", data.FieldType("unknown"), false, 0)

		assert.Nil(t, f)
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "invalid field type")
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty name", func(t *testing.T) {
		f, err := data.NewDataField(d.ID, "", "Label", data.FieldTypeText, false, 0)

		assert.Nil(t, f)
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "name")
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty label", func(t *testing.T) {
		f, err := data.NewDataField(d.ID, "name", "", data.FieldTypeText, false, 0)

		assert.Nil(t, f)
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "label")
		t.Log("Status: PASSED")
	})
}

func TestDataFieldTypeConstants(t *testing.T) {
	t.Log("=== Scenario: FieldType Constants ===")
	t.Log("Goal: Verify all FieldType constants are defined and in ValidFieldTypes map")

	types := []data.FieldType{
		data.FieldTypeText,
		data.FieldTypeTextarea,
		data.FieldTypeNumber,
		data.FieldTypeEmail,
		data.FieldTypeURL,
		data.FieldTypePhone,
		data.FieldTypeDate,
		data.FieldTypeSelect,
		data.FieldTypeCheckbox,
		data.FieldTypeImageURL,
		data.FieldTypeRichText,
		data.FieldTypeRelation,
	}

	for _, ft := range types {
		assert.True(t, data.ValidFieldTypes[ft], "expected %s to be valid", ft)
	}
	assert.Equal(t, 12, len(data.ValidFieldTypes))
	t.Log("Result: All 12 field type constants validated")
	t.Log("Status: PASSED")
}

func TestDataTypeNewIDGenerated(t *testing.T) {
	t.Log("=== Scenario: DataType ID Uniqueness ===")
	t.Log("Goal: Each NewDataType call generates a unique UUID")

	d1, _ := data.NewDataType(uuid.UUID{}, "D1", "d1", "D1s", "content", 1, nil, nil)
	d2, _ := data.NewDataType(uuid.UUID{}, "D2", "d2", "D2s", "content", 2, nil, nil)

	assert.NotEqual(t, d1.ID, d2.ID)
	t.Log("Status: PASSED")
}

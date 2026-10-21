// Package yamlprofiles reads profiles/<iso2|engine>/<profileId>.yaml
// (ADR-008) as the JSON documents they denote, for ports.ProfileSource.
// The mapping matches geo_salah_profiles/tool/yaml_json.dart: maps with
// string keys, lists, strings, numbers, booleans and null. Anything else
// (anchors and aliases, merge keys, tags, non-decimal or non-JSON numbers,
// duplicate keys, several documents) is refused rather than guessed.
package yamlprofiles

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"io/fs"
	"os"
	"regexp"
	"slices"
	"strconv"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/profileset"
	"go.yaml.in/yaml/v3"
)

// pattern is where profiles live, relative to the profiles directory.
const pattern = "*/*.yaml"

var (
	jsonInteger = regexp.MustCompile(`^-?(?:0|[1-9][0-9]*)$`)
	jsonNumber  = regexp.MustCompile(`^-?(?:0|[1-9][0-9]*)(?:\.[0-9]+)?(?:[eE][+-]?[0-9]+)?$`)
)

// ErrNotJSONData is returned for YAML that is not plain JSON data.
var ErrNotJSONData = errors.New("yaml is not plain JSON data")

// Source reads the profiles under Dir.
type Source struct {
	Dir string
}

// LoadProfiles returns every */*.yaml document under Dir, sorted by path.
func (s Source) LoadProfiles(ctx context.Context) ([]profileset.Document, error) {
	root, err := os.OpenRoot(s.Dir)
	if err != nil {
		return nil, fmt.Errorf("open profiles directory: %w", err)
	}
	defer root.Close() //nolint:errcheck // read-only handle; nothing to flush
	paths, err := fs.Glob(root.FS(), pattern)
	if err != nil {
		return nil, fmt.Errorf("list profiles: %w", err)
	}
	slices.Sort(paths)
	docs := make([]profileset.Document, 0, len(paths))
	for _, p := range paths {
		if err := ctx.Err(); err != nil {
			return nil, err
		}
		data, err := root.ReadFile(p)
		if err != nil {
			return nil, fmt.Errorf("read %s: %w", p, err)
		}
		doc, err := ToJSON(data)
		if err != nil {
			return nil, fmt.Errorf("%s: %w", p, err)
		}
		docs = append(docs, profileset.Document{Path: p, JSON: doc})
	}
	return docs, nil
}

// ToJSON converts one YAML document to JSON text.
func ToJSON(data []byte) ([]byte, error) {
	dec := yaml.NewDecoder(bytes.NewReader(data))
	var doc yaml.Node
	if err := dec.Decode(&doc); err != nil {
		return nil, fmt.Errorf("parse yaml: %w", err)
	}
	var extra yaml.Node
	if err := dec.Decode(&extra); !errors.Is(err, io.EOF) {
		return nil, fmt.Errorf("%w: more than one document", ErrNotJSONData)
	}
	var out bytes.Buffer
	if err := write(&out, &doc); err != nil {
		return nil, err
	}
	return out.Bytes(), nil
}

func write(out *bytes.Buffer, n *yaml.Node) error {
	if n.Anchor != "" {
		return fmt.Errorf("%w: anchor &%s at line %d", ErrNotJSONData, n.Anchor, n.Line)
	}
	switch n.Kind {
	case yaml.DocumentNode:
		if len(n.Content) != 1 {
			return fmt.Errorf("%w: empty document", ErrNotJSONData)
		}
		return write(out, n.Content[0])
	case yaml.MappingNode:
		return writeMapping(out, n)
	case yaml.SequenceNode:
		out.WriteByte('[')
		for i, item := range n.Content {
			if i > 0 {
				out.WriteByte(',')
			}
			if err := write(out, item); err != nil {
				return err
			}
		}
		out.WriteByte(']')
		return nil
	case yaml.ScalarNode:
		return writeScalar(out, n)
	case yaml.AliasNode:
		return fmt.Errorf("%w: alias at line %d", ErrNotJSONData, n.Line)
	default:
		return fmt.Errorf("%w: node kind %d at line %d", ErrNotJSONData, n.Kind, n.Line)
	}
}

func writeMapping(out *bytes.Buffer, n *yaml.Node) error {
	seen := map[string]bool{}
	out.WriteByte('{')
	for i := 0; i+1 < len(n.Content); i += 2 {
		key := n.Content[i]
		if key.Kind != yaml.ScalarNode || key.ShortTag() != "!!str" {
			return fmt.Errorf("%w: non-string key %q at line %d", ErrNotJSONData, key.Value, key.Line)
		}
		if seen[key.Value] {
			return fmt.Errorf("%w: duplicate key %q at line %d", ErrNotJSONData, key.Value, key.Line)
		}
		seen[key.Value] = true
		if i > 0 {
			out.WriteByte(',')
		}
		if err := writeString(out, key.Value); err != nil {
			return err
		}
		out.WriteByte(':')
		if err := write(out, n.Content[i+1]); err != nil {
			return err
		}
	}
	out.WriteByte('}')
	return nil
}

func writeScalar(out *bytes.Buffer, n *yaml.Node) error {
	switch n.ShortTag() {
	case "!!str", "!!timestamp": // a date stays the text it is, as in Dart's yaml
		return writeString(out, n.Value)
	case "!!null":
		out.WriteString("null")
	case "!!bool":
		var b bool
		if err := n.Decode(&b); err != nil {
			return fmt.Errorf("%w: boolean %q at line %d", ErrNotJSONData, n.Value, n.Line)
		}
		out.WriteString(strconv.FormatBool(b))
	case "!!int":
		if !jsonInteger.MatchString(n.Value) {
			return fmt.Errorf("%w: integer %q at line %d is not decimal", ErrNotJSONData, n.Value, n.Line)
		}
		out.WriteString(n.Value)
	case "!!float":
		if !jsonNumber.MatchString(n.Value) {
			return fmt.Errorf("%w: number %q at line %d is not a JSON number", ErrNotJSONData, n.Value, n.Line)
		}
		out.WriteString(n.Value)
	default:
		return fmt.Errorf("%w: tag %s at line %d", ErrNotJSONData, n.ShortTag(), n.Line)
	}
	return nil
}

func writeString(out *bytes.Buffer, s string) error {
	quoted, err := json.Marshal(s)
	if err != nil {
		return fmt.Errorf("encode string: %w", err)
	}
	out.Write(quoted)
	return nil
}

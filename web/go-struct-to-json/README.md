# Go Struct → JSON Mock Generator V3

## New in V3

### 1. Root Struct selector

You can paste multiple structs and choose which one should be used as the root.

Example:

```text
Root Struct:
AdjustmentRequestBody

Root JSON Key:
adjustment_request_body
```

The generated output will use `AdjustmentRequestBody`.

### 2. JSON Pretty button

The new `JSON Pretty` button formats the generated JSON with 4-space indentation.

### 3. Structs without `type`

The parser now supports both:

```go
type HelloWorld struct {
    Body ExampleBody `json:"example_body"`
}
```

and:

```go
HelloWorld struct {
    Body ExampleBody `json:"example_body"`
}
```

This is useful when copying struct definitions from generated documentation, snippets, or other sources.

## Example

Input:

```go
HelloWorld struct {
    Body ExampleBody `json:"example_body"`
}

ExampleBody struct {
    Test         null.Int64  `json:"test"`
    Apple        null.String `json:"apple"`
}
```

Select:

```text
Root Struct: HelloWorld
Root JSON Key: rq_body
```

Output:

```json
{
    "rq_body": {
        "example_body": {
            "test": -1,
            "apple": "mock-string"
        }
    }
}
```

## Buttons

- `Generate JSON` — Generate JSON from the selected root struct.
- `JSON Pretty` — Format the generated JSON with indentation.
- `Copy JSON` — Copy JSON to clipboard.
- `Clear` — Clear the input and output.

## Supported

- Go primitive types
- `json` struct tags
- Nested structs
- Structs with or without `type`
- Pointers
- Slices
- Arrays
- Maps
- `null.Int64`
- `null.Int32`
- `null.String`
- `null.Dec2`
- `null.Date`
- `time.Time`
- Custom `mock:"..."` values

## Custom mock values

Example:

```go
HelloWorld struct {
    Test    string `json:"test" mock:"text"`
    Apple   string `json:"apple" mock:"-200000"`
}
```

Output:

```json
{
    "test": "text",
    "apple": -200000
}
```

## Important

If two structs have exactly the same name in the pasted input, the later definition will replace the earlier one. In real Go code, duplicate type names are not allowed in the same package.

For types with the same name from different packages, package-aware resolution would be needed.

## 素朴な設計

```mermaid
erDiagram
Folders {
  integer id
  string name
  integer parent_id
}

Folders ||--o{ Folders:"parent"

```

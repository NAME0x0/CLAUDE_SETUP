# Merge the template settings (.[1]) into existing settings (.[0]).
# Template values win for scalar keys; objects merge recursively.
# permissions.allow and each hooks.<Event> array are unioned so nothing the
# user already had is dropped.
def union(a; b): ((a // []) + (b // [])) | unique;

(.[0] // {}) as $old
| (.[1] // {}) as $new
| ($old * $new)
| .permissions.allow = union($old.permissions.allow; $new.permissions.allow)
| .hooks = (
    reduce ((($old.hooks // {}) + ($new.hooks // {})) | keys[]) as $k
      ({}; .[$k] = union($old.hooks[$k]; $new.hooks[$k]))
  )

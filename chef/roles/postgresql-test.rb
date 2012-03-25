name "postgresql-test"
description "PostgreSQL Client Role"
run_list(
         "recipe[postgresql::client]",
         "recipe[postgresql::test]"
)
default_attributes()
override_attributes()


name "postgresql-client"
description "PostgreSQL Client Role"
run_list(
         "recipe[postgresql::client]"
)
default_attributes()
override_attributes()


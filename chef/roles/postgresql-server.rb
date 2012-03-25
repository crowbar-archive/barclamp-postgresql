name "postgresql-server"
description "PostgreSQL Server Role"
run_list(
         "recipe[postgresql::server]"
)
default_attributes()
override_attributes()


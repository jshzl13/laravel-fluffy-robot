# Application Code Guidance

- Use `php artisan make:` commands with `--no-interaction` for Laravel-generated files. Use `make:class` for generic PHP classes.
- Keep controllers, models, services, and other application code consistent with nearby files. Prefer framework features and established application abstractions over new helpers or dependencies.
- Use descriptive variable and method names. Use explicit parameter and return types, and constructor property promotion when dependencies are injected; do not leave an empty zero-argument constructor unless it is private.
- Use curly braces for every control structure and TitleCase enum keys. Prefer PHPDoc blocks to inline comments, and use array shapes where they clarify structured arrays.
- Use `route()` and named routes for application links.
- Default to Eloquent API Resources and API versioning only when that matches the existing route conventions.
- Keep database access out of Blade views and avoid hidden N+1 queries.
- Use `php artisan list` and `php artisan <command> --help` to discover generator and command options. Read configuration through `php artisan config:show <key>` or the relevant file in `config/`.
- For debugging in application context, use existing Artisan commands before Tinker. When Tinker is necessary, pass the expression with single shell quotes.
- Run `vendor/bin/pint --dirty --format agent` after modifying PHP files.

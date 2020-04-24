component name="Main Controller" accessors=true
	output=false
{
	property MigrationService;

	void function default( rc ) {
		var migrationService = variables.MigrationService;
		rc.migrations = migrationService.findAll();
	}

	void function up( rc ) {
		var migrationService = variables.MigrationService;
		migrationService.install();
		migrationService.runAllMigrations( "up" );

		rc.message = "Migrations Up";
	}

	void function down( rc ) {
		var migrationService = variables.MigrationService;
		migrationService.install();
		migrationService.runAllMigrations( "down" );

		rc.message = "Migrations Down";
	}
}

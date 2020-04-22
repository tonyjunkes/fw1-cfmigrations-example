component extends="testbox.system.BaseSpec" {
	function __config() {
		return variables.framework;
	}

	function initFW1App() {
		// Reset the framework instance before each spec is run
		request.delete( "_fw1" );
		variables.fw = new framework.one();
		variables.fw.__config = __config;
		variables.fw.__config().append({
			diEngine: "di1",
			diLocations: [ "/model" ],
			diConfig: {
				loadListener: ( di1 ) => {
					// Create an impersonation of WireBox :D
					di1.declare( "WireBox" ).asValue({
						getInstance: ( name, initArguments = {} ) => {
							// Check if a CFC path was passed and instantiate it
							if ( fileExists( expandPath( name.replace( ".", "/", "all" ) & ".cfc" ) ) ) {
								return createObject( "component", name );
							}
							// Otherwise it's a bean to fetch from a bean factory
							else {
								// Parse object@module to get subsystem
								var module = name.listToArray( "@" ).last();
								return variables.fw.getBeanFactory( module ).getBean( name, initArguments );
							}
						}
					});
					// Migration Service
					di1.declare( "MigrationService" ).asValue(
						variables.fw.getBeanFactory( "cfmigrations" ).getBean( "MigrationService" )
							.setDatasource( getApplicationMetadata().datasource )
							.setDefaultGrammar( "MySQLGrammar@qb" )
							.setMigrationsDirectory( "/resources/database/migrations" )
							.setMigrationsTable( "cfmigrations" )
							.setWireBox( di1.getBean( "WireBox" ) )
					);
				}
			},
			subsystems: {
				qb: {
					diLocations: [ "/qb/models" ],
					diConfig: {
						loadListener: ( di1 ) => {
							di1.declare( "MySQLGrammar" ).instanceOf( "qb.models.Grammars.MySQLGrammar" ).done()
								.declare( "QueryUtils" ).instanceOf( "qb.models.Query.QueryUtils" ).done()
								.declare( "QueryBuilder" ).instanceOf( "qb.models.Query.QueryBuilder" )
								.withOverrides({
									grammar: di1.getBean( "MySQLGrammar" ),
									utils: di1.getBean( "QueryUtils" ),
									returnFormat: "array"
								}).done()
								.declare( "SchemaBuilder" ).instanceOf( "qb.models.Schema.SchemaBuilder" )
								.asTransient()
								.withOverrides({
									grammar: di1.getBean( "MySQLGrammar" )
								}).done()
								// Aliases
								.declare( "MySQLGrammar@qb" ).aliasFor( "MySQLGrammar" ).done()
								.declare( "QueryBuilder@qb" ).aliasFor( "QueryBuilder" ).done()
								.declare( "SchemaBuilder@qb" ).aliasFor( "SchemaBuilder" );
						}
					}
				},
				cfmigrations: {
					diLocations: [ "/models" ]
				}
			}
		});
		variables.fw.onApplicationStart();
	}

	/*********************************** BDD SUITES ***********************************/

	function afterAll() {
		queryExecute( "DROP ALL OBJECTS DELETE FILES" );
	}

	function run() {
		describe( "Migrations", function() {
			beforeEach(function( currentSpec ){
				initFW1App();
				migrationService = variables.fw.getBeanFactory().getBean( "MigrationService" );
				migrationService.install();
			});

			it ( "can be run UP", function() {
				migrationService.runAllMigrations( "up" );
				var users = queryExecute( "SELECT * FROM users" );

				expect( users ).toHaveLength( 1 );
				expect( users.email ).toBe( "user@test.com" );
				expect( users.password ).toBe( "secretpassword" );
			});

			it ( "can be run DOWN", function() {
				migrationService.runAllMigrations( "down" );
				var tables = queryExecute( "SHOW TABLES" );
				//var migrationsTable = tables.filter( (table) => { table.TABLE_NAME == "users" } );

				//expect( migrationsTable ).toHaveLength( 0 );
			});
		});
	}
}

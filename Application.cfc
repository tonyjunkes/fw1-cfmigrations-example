component extends="framework.one"
	output="false"
{
	this.applicationTimeout = createTimeSpan( 0, 2, 0, 0 );
	this.setClientCookies = true;
	this.sessionManagement = true;
	this.sessionTimeout = createTimeSpan( 0, 0, 30, 0 );
	this.mappings = {
		"/cfmigrations" = expandPath( "./subsystems/cfmigrations" ),
		"/qb" = expandPath( "./subsystems/cfmigrations/modules/qb" )
	};
	this.datasource = "cfmigrations_example";
	this.datasources[ this.datasource ] = {
		class: "org.h2.Driver",
		connectionString: "jdbc:h2:#expandPath( "./resources/database/" & this.datasource )#;MODE=MySQL"
	};

	// FW/1 settings
	variables.framework = {
		defaultSection: "main",
		defaultItem: "default",
		error: "main.error",
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
							return getBeanFactory( module ).getBean( name, initArguments );
						}
					}
				});
				// Migration Service
				di1.declare( "MigrationService" ).asValue(
					getBeanFactory( "cfmigrations" ).getBean( "MigrationService" )
						.setDatasource( this.datasource )
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
		},
		trace: true,
		reloadApplicationOnEveryRequest: true,
		routes: [
			{ "/up": "/main/up" },
			{ "/down": "/main/down" },
			{ "/": "/main/default" }
		]
	};
}
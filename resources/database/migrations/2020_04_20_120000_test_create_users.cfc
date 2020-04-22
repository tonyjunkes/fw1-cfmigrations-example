component {
    function up( SchemaBuilder schema, QueryBuilder query ) {
        schema.create( "users", function( Blueprint table ) {
            table.increments( "id" );
            table.string( "email" );
            table.string( "password" );
        });
    }

    function down( SchemaBuilder schema, QueryBuilder query ) {
        schema.dropIfExists( "users" );
    }
}
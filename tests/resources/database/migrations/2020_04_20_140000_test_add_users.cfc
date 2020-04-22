component {
    function up( SchemaBuilder schema, QueryBuilder query ) {
        query.from( "users" )
            .insert({
                "email" = "user@test.com",
                "password" = "secretpassword"
            });
    }

    function down( SchemaBuilder schema, QueryBuilder query ) {
        query.from( "users" )
            .where( "email", "user@test.com" )
            .delete();
    }
}
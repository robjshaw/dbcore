<cfcomponent output="false">
	
	<cffunction name="get" access="public">
		<cfargument name="type" required="true" />
		<cfargument name="stArguments" required="true" />

		<cfscript>
			var qGet = "";
			var aColumns = arrayNew(1);
			var lWant = '';
			var result = '';

			var queryOrderBy = 'ASC';
			var querylimitBy = 10;

			if (structKeyExists(arguments.stArguments, 'want')){
				lWant = arguments.stArguments.want;
			}

			if (structKeyExists(arguments.stArguments, 'limitBy')){
				querylimitBy = arguments.stArguments.limitBy;
			}

			if (structKeyExists(arguments.stArguments, 'orderBy')){
				queryOrderBy = arguments.stArguments.orderBy = 'ASC';
			}
		</cfscript>

		<cfloop collection="#arguments.stArguments#" item="i">
			<cfscript>
				if ((i neq 'want') and (i neq 'limitBy') and (i neq 'orderBy')){
					arrayAppend(aColumns, i);
				}
			</cfscript>
		</cfloop>

		<cfscript>
			if (listLen(lWant) eq 0){
				lWant = '*';
			}
		</cfscript>

		<cfquery datasource="#request.dsn#" name="qGet">
			SELECT #lWant#
			FROM #arguments.type#
			WHERE 1 = 1
			<cfloop from="1" to="#arrayLen(aColumns)#" index="k">
				<cfif isNumeric(stArguments[aColumns[k]])>
					AND #aColumns[k]# = <cfqueryparam value="#arguments.stArguments[aColumns[k]]#" cfsqltype="cf_sql_integer" />
				<cfelse>
					AND #aColumns[k]# = <cfqueryparam value="#arguments.stArguments[aColumns[k]]#" cfsqltype="cf_sql_varchar" />
				</cfif>
			</cfloop>
			LIMIT #querylimitBy#
		</cfquery>

		<cfscript>
			result = qGet;

			return result;
		</cfscript>

	</cffunction>

	<cffunction name="create" access="public">
		<cfargument name="type" required="true" />
		<cfargument name="stArguments" required="true" />

		<cfscript>
			var aColumns = arrayNew(1);
			var rInserted = '';
			var stGetArguments = structNew();
		</cfscript>

		<cfloop collection="#arguments.stArguments#" item="i">
			<cfscript>
				if (i neq 'want'){
					arrayAppend(aColumns, i);
				}
			</cfscript>
		</cfloop>

		<cfquery datasource="#request.dsn#" result="rInserted">
			INSERT INTO #arguments.type# (#arrayToList(aColumns)#, dtInserted)
			VALUES (	<cfloop from="1" to="#arrayLen(aColumns)#" index="k">
							<cfif isNumeric(stArguments[aColumns[k]])>
								<cfqueryparam value="#stArguments[aColumns[k]]#" cfsqltype="cf_sql_integer" />
							<cfelse>
								<cfqueryparam value="#stArguments[aColumns[k]]#" cfsqltype="cf_sql_varchar" />
							</cfif>
							,
						</cfloop>
						now()
					)
		</cfquery>

		<cfscript>
			stGetArguments['#type#id'] = rInserted.generatedKey;
			result = get(type=arguments.type,stArguments=stGetArguments);

			return result;
		</cfscript>

	</cffunction>

	<cffunction name="update" access="public">
		<cfargument name="type" required="true" />
		<cfargument name="stArguments" required="true" />

		<cfscript>
			var stGetArguments = structNew();
			var result = '';
		</cfscript>

		<cfquery datasource="#request.dsn#" result="q">
			UPDATE #arguments.type#
			SET 
				<cfloop collection="#arguments.stArguments#" item="i">
					<cfif i neq (arguments.type & 'id')>
						#i# = 
							<cfif isNumeric(stArguments[i])>
								<cfqueryparam value="#stArguments[i]#" cfsqltype="cf_sql_integer" />
							<cfelse>
								<cfqueryparam value="#stArguments[i]#" cfsqltype="cf_sql_varchar" />
							</cfif>
						,
					</cfif>
				</cfloop>
				dtUpdated = now()
			WHERE #type & 'id'# = #stArguments[arguments.type & 'id']#
		</cfquery>

		<cfscript>
			stGetArguments['#type#id'] = stArguments['#type#id'];
			result = get(type=arguments.type,stArguments=stGetArguments);

			return result;
		</cfscript>

	</cffunction>

	<cffunction name="delete" access="remote">
		<cfargument name="type" required="true" />
		<cfargument name="stArguments" required="true" />

		<cfscript>
			var aColumns = arrayNew(1);
			result = true;
		</cfscript>

		<cfloop collection="#arguments.stArguments#" item="i">
			<cfscript>
				arrayAppend(aColumns, i);
			</cfscript>
		</cfloop>

		<cfquery datasource="#request.dsn#" result="r">
			DELETE FROM #arguments.type#
			<!---
			WHERE #arguments.type & 'id'# = #stArguments[arguments.type & 'id']#
			--->
			WHERE 1 = 1

			<cfloop from="1" to="#arrayLen(aColumns)#" index="k">
				<cfif isNumeric(stArguments[aColumns[k]])>
					AND #aColumns[k]# = <cfqueryparam value="#arguments.stArguments[aColumns[k]]#" cfsqltype="cf_sql_integer" />
				<cfelse>
						AND #aColumns[k]# = <cfqueryparam value="#arguments.stArguments[aColumns[k]]#" cfsqltype="cf_sql_varchar" />
				</cfif>
			</cfloop>
		</cfquery>

		<!--- we need to delete relationships in other tables --->

		<cfreturn result />

	</cffunction>

	<!--- Utility FUNCTIONS --->

	<cffunction name="getTitle" output="false">
		<cfargument name="typeid" required="true">
		<cfargument name="type" required="true">

		<cfscript>
			var qGet = "";

			var where = "#type#id";
		</cfscript>

		<cfquery datasource="#request.dsn#" name="qGet">
			SELECT title
			FROM #arguments.type#
			WHERE #where# = <cfqueryparam value="#arguments.typeid#" cfsqltype="cf_sql_integer" />
		</cfquery>

		<cfreturn qGet.title />
	</cffunction>

	<cffunction name="getCount" output="false">
		<cfargument name="typeid" required="true">
		<cfargument name="type" required="true">
		<cfargument name="where" required="true">

		<cfscript>
			var qGet = "";

			//var where = "#type#id";
		</cfscript>

		<cfquery datasource="#request.dsn#" name="qGet">
			SELECT count(*) as rCount
			FROM #arguments.type#
			WHERE #arguments.where# = <cfqueryparam value="#arguments.typeid#" cfsqltype="cf_sql_integer" />
		</cfquery>

		<cfreturn qGet.rCount />
	</cffunction>



</cfcomponent>
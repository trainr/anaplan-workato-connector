{
  title: 'Anaplan Connector',

  connection: {
    fields: [
      {
        name: 'environment',
        label: 'Tenant Environment',
        control_type: 'select',
        options: [
          ['Anaplan DC', ''],
          ['AWS Australia DC', 'au1a.app2.']
        ]
      },
      {
        name: 'username',
        optional: true,
        hint: 'Your email used for login'
      },
      {
        name: 'password',
        control_type: 'password',
      }
    ],

    authorization: {
      type: 'custom_auth',

      acquire: lambda do |connection|

        userpass = (connection["username"] + ":" + connection["password"]).encode_base64
        response = post("https://auth.#{connection['environment']}anaplan.com/token/authenticate").headers("Authorization": "Basic " + userpass).request_format_www_form_urlencoded
        {
          response: response,
          tokenValue: response['tokenInfo']['tokenValue']
        }

      end,

      apply: lambda do |connection|
        if current_url.include?("https://auth.#{connection['environment']}anaplan.com/token/authenticate")
          #user(connection["username"])
          #password(connection["password"])
        else
          headers("Authorization": "AnaplanAuthToken #{connection['tokenValue']}")
          #headers("Authorization": "AnaplanAuthToken #{connection['tokenValue']}", "MyHeader": "#{connection['tokenValue']}")
        end
      end,

      refresh_on: [401, 403]
    },

    base_uri: lambda do |connection|
      "https://api.#{connection['environment']}anaplan.com/"
    end
  },

  test: lambda do |connection|
    get("https://api.#{connection['environment']}anaplan.com/2/0/objects/workspace")
    #get('https://api.anaplan.com/2/0/workspaces')

  end,

  object_definitions: {
    #  Object definitions can be referenced by any input or output fields in actions/triggers.
    #  Use it to keep your code DRY. Possible arguments - connection, config_fields
    #  See more at https://docs.workato.com/developing-connectors/sdk/sdk-reference/object_definitions.html
    workspace: {
      fields: lambda do
        [
          { name: "id" },
          { name: "name"},
          { name: "active", type: "boolean" },
          { name: "sizeAllowance", type: "integer" },
          { name: "currentSize", type: "integer" }
        ]
      end
    },
    workspaces: {
      fields: lambda do
        [
          { name: "workspaces",
            type: "array",
            of: "object",
            properties: [
              { name: "id" },
              { name: "name"},
              { name: "active", type: "boolean" },
              { name: "sizeAllowance", type: "integer" },
              { name: "currentSize", type: "integer" }
            ]
          }
        ]
      end
    },

    models: {
      fields: lambda do
        [
          { name: "models",
            type: "array",
            of: "object",
            properties: [
              { name: "id" },
              { name: "name"},
              { name: "activeState"},
              { name: "currentWorkspaceId"},
              { name: "currentWorkspaceName"},
              { name: "modelUrl", type: "url"},
              { name: "categoryValues",
                type: "array",
                propertieis: [
                  name: "category"
                ]},

            ]
          }
        ]
      end
    },

    model: {
      fields: lambda do
        [
          { name: "id" },
          { name: "name"},
          { name: "activeState"},
          { name: "currentWorkspaceId"},
          { name: "currentWorkspaceName"},
          { name: "modelUrl", type: "url"},
          { name: "categoryValues",
            type: "array",
            propertieis: [
              name: "category"
            ]}
        ]
      end
    },

    imports: {
      fields: lambda do
        [
          { name: "imports",
            type: "array",
            of: "object",
            properties: [
              { name: "id" },
              { name: "name"},
              { name: "importDataSourceId"},
              { name: "importType"}
            ]
          }
        ]
      end
    },

    importMetadata: {
      fields: lambda do
        [
          {name: "meta",
           type: "object",
           properties: [
             {name: "schema"}
           ]
          },
          { name: "status",
            type: "object",
            properties: [
              {name: "code", type: "integer"},
              {name: "message"}
            ]},
          {name: "importMetadata",
           type: "object",
           properties: [
             {name: "name"},
             {name: "type"},
             {name: "source",
              type: "object",
              properties: [
                {name: "textEncoding"},
                {name: "columnSeparator"},
                {name: "textDelimiter"},
                {name: "headerRow", type: "integer"},
                {name: "firstDataRow", type: "integer"},
                {name: "decimalSeparator"},
                {name: "headerNames", type: "array", of: "string"},
                {name: "columnCount", type: "integer"}
              ]
             }
           ]
          }
        ]
      end
    },

    exports: {
      fields: lambda do
        [
          {name: "meta",
           type: "object",
           properties: [
             {name: "paging",
              type: "object",
              properties: [
                {name: "currentPageSize", type: "integer"},
                {name: "offset", type: "integer"},
                {name: "totalSize", type: "integer"}
              ]},
             {name: "schema"}
           ]
          },
          { name: "status",
            type: "object",
            properties: [
              {name: "code", type: "integer"},
              {name: "message"}
            ]},
          {name: "exports",
           type: "array",
           of: "object",
           properties: [
             {name: "id"},
             {name: "name"},
             {name: "exportType"}
           ]
          }
        ]
      end
    },

    exportMetadata: {
      fields: lambda do
        [
          {name: "meta",
           type: "object",
           properties: [
             {name: "schema"}
           ]
          },
          { name: "status",
            type: "object",
            properties: [
              {name: "code", type: "integer"},
              {name: "message"}
            ]},
          {name: "exportMetadata",
           type: "object",
           properties: [
             {name: "columnCount", type: "integer"},
             {name: "dataTypes",
              type: "array"},
             {name: "delimiter"},
             {name: "encoding"},
             {name: "exportFormat"},
             {name: "headerNames",
              type: "array"},
             {name: "listNames",
              type: "array"},
             {name: "rowCount", type: "integer"},
             {name: "separator"}
           ]
          }
        ]
      end
    },

    exports_metadata: {
      fields: lambda do
        [
          { name: "exports",
            type: "array",
            of: "object",
            properties: [
              {name: "id"},
              {name: "name"},
              {name: "exportType"},
              {name: "exportFormat"},
              {name: "encoding"},
              {name: "layout"},
              {name: "columnCount", type: "integer"},
              {name: "dataTypes",
               type: "array",
               of: "object",
               properties: [
                 name: "dataType"
               ]},
              {name: "delimiter"},
              {name: "encoding"},
              {name: "exportFormat"},
              {name: "headerNames",
               type: "array",
               of: "object",
               properties: [
                 name: "headerName"
               ]},
              {name: "listNames",
               type: "array",
               of: "object",
               properties: [
                 name: "listName"
               ]},
              {name: "rowCount", type: "integer"},
              {name: "separator"}
            ]
          }
        ]
      end
    },

    processes_metadata: {
      fields: lambda do
        [
          { name: "processes",
            type: "array",
            of: "object",
            properties: [
              {name: "id"},
              {name: "name"},
              {name: "actions",
               type: "array",
               of: "object",
               properties: [
                 {name: "id"},
                 {name: "name"},
                 {name: "actionType"},
                 {name: "importDataSourceId"},
                 {name: "importType"},
                 {name: "importDataSource",
                  type: "object",
                  properties: [
                    {name: "importDataSourceId"},
                    {name: "type"},
                    {name: "sourceModelId"},
                    {name: "sourceWorkspaceId"}
                  ]
                 }
               ]
              }
            ]
          }
        ]
      end
    },

    files: {
      fields: lambda do
        [
          {name: "files",
           type: "array",
           of: "object",
           properties: [
             { name: "id" },
             { name: "name"},
             { name: "chunkCount", type: "integer"},
             { name: "delimiter"},
             { name: "encoding"},
             { name: "firstDataRow", type: "integer"},
             { name: "format"},
             { name: "headerRow", type: "integer"},
             { name: "separator"}
           ]
          }
        ]
      end
    },

    modules: {
      fields: lambda do
        [
          { name: "modules",
            type: "array",
            of: "object",
            properties: [
              { name: "id" },
              { name: "name"}
            ]
          }
        ]
      end
    },

    module: {
      fields: lambda do
        [
          { name: "id" },
          { name: "name"}
        ]
      end
    },

    lists: {
      fields: lambda do
        [
          { name: "lists",
            type: "array",
            of: "object",
            properties: [
              { name: "id" },
              { name: "name"}
            ]
          }
        ]
      end
    },

    lists_metadata: {
      fields: lambda do
        [
          { name: "lists",
            type: "array",
            of: "object",
            properties: [
              { name: "id" },
              { name: "name"},
              { name: "properties",
                type: "array",
                of: "object",
                properties: [
                  {name: "id"},
                  {name: "name"},
                  {name: "format"},
                  {name: "formatMetadata",
                   type: "object",
                   properties: [
                     {name: "dataType"},
                     {name: "minimumSignificantDigits", type: "integer"},
                     {name: "decimalPlaces", type: "integer"},
                     {name: "negativeNumberNotation"},
                     {name: "unitsType"},
                     {name: "unitsDisplayType"},
                     {name: "zeroFormat"},
                     {name: "comparisonIncrease"},
                     {name: "groupingSeparator"},
                     {name: "decimalSeparator"},
                     {name: "selectivedAccessApplied", type: "boolean"},
                     {name: "showAll", type: "boolean"},
                     {name: "hierarchyEntityLongId"},
                     {name: "textType"},
                     {name: "periodType",
                      type: "object",
                      properties: [
                        {name: "entityId"},
                        {name: "entityLabel"},
                        {name: "entityIndex", type: "integer"}
                      ]
                     }
                   ]
                  },
                  {name: "formula"},
                  {name: "notes"},
                  {name: "referencedBy"}
                ]
              },
              {name: "hasSelectiveAccess", type: "boolean"},
              {name: "parent",
               type: "object",
               properties: [
                 {name: "id"},
                 {name: "name"}
               ]
              },
              { name: "subsets",
                type: "array",
                of: "object",
                properties: [
                  {name: "id"},
                  {name: "name"}
                ]
              },
              {name: "productionData", type: "boolean"},
              {name: "managedBy"},
              {name: "numberedList", type: "boolean"},
              {name: "useTopLevelAsPageDefault", type: "boolean"},
              {name: "itemCount", typ: "integer"},
              {name: "workflowEnabled", type: "boolean"},
              {name: "permittedItems", type: "integer"},
              {name: "usedInAppliesTo"},
              {name: "usedAsFormat"},
              {name: "usedInFormula"}
            ]
          }
        ]
      end
    },

    lineItemsSimple: {
      fields: lambda do
        [
          {name: "items",
           type: "array",
           of: :object,
           properties: [
             {name: "moduleId"},
             {name: "moduleName"},
             {name: "id"},
             {name: "name"}
           ]
          }
        ]
      end
    },


    lineItemsDetailed: {
      fields: lambda do
        [
          {name: "items",
           type: "array",
           of: :object,
           properties: [
             {name: "moduleId"},
             {name: "moduleName"},
             {name: "id"},
             {name: "name"},
             {name: "isSummary", type: "boolean"},
             {name: "startOfSection", type: "boolean"},
             {name: "broughtForward", type: "boolean"},
             {name: "useSwitchover", type: "boolean"},
             {name: "breakback", type: "boolean"},
             {name: "cellCount", type: "integer"},
             {name: "version",
              type: "object",
              properties: [
                {name: "name"},
                {name: "id"}
              ]
             },
             {name: "appliesTo",
              type: "array",
              of: "object",
              properties: [
                {name: "name"},
                {name: "id"}
              ]
             },
             {name: "dataTags",
              type: "array",
              of: "object",
              properties: [
                {name: "name"},
                {name: "id"}
              ]
             },
             {name: "referencedBy",
              type: "array",
              of: "object",
              properties: [
                {name: "name"},
                {name: "id"}
              ]
             },
             {name: "parent",
              type: "object",
              properties: [
                {name: "name"},
                {name: "id"}
              ]
             },
             {name: "readAccessDriver",
              type: "object",
              properties: [
                {name: "name"},
                {name: "id"}
              ]
             },
             {name: "writeAccessDriver",
              type: "object",
              properties: [
                {name: "name"},
                {name: "id"}
              ]
             },
             {name: "formula"},
             {name: "format"},
             {name: "formatMetadata",
              type: "object",
              properties: [
                {name: "dataType"},
                {name: "minimumSignificantDigits", type: "integer"},
                {name: "decimalPlaces", type: "integer"},
                {name: "negativeNumberNotation"},
                {name: "unitsType"},
                {name: "unitsDisplayType"},
                {name: "zeroFormat"},
                {name: "comparisonIncrease"},
                {name: "groupingSeparator"},
                {name: "decimalSeparator"},
                {name: "selectivedAccessApplied", type: "boolean"},
                {name: "showAll", type: "boolean"},
                {name: "hierarchyEntityLongId"},
                {name: "textType"},
                {name: "periodType",
                 type: "object",
                 properties: [
                   {name: "entityId"},
                   {name: "entityLabel"},
                   {name: "entityIndex", type: "integer"}
                 ]
                }
              ]
             },
             {name: "summary"},
             {name: "timeScale"},
             {name: "timeRange"},
             {name: "formulaScope"},
             {name: "style"},
             {name: "code"},
             {name: "notes"}
           ]
          }
        ]
      end
    },

    revision: {
      fields: lambda do
        [
          {name: "meta",
           type: "object",
           properties: [
             name: "schema"
           ]},
          {name: "status",
           type: "object",
           properties: [
             {name: "code", type: "integer"},
             {name: "message"}
           ]},
          {name: "revision",
           type: "object",
           properties: [
             {name: "id"},
             {name: "name"},
             {name: "description"},
             {name: "createdOn"},
             {name: "createdBy"},
             {name: "creationMethod"},
             {name: "appliedOn"},
             {name: "appliedBy"}
           ]
          }
        ]
      end
    },

    revision_one: {
      fields: lambda do
        [
          {name: "revision",
           type: "object",
           properties: [
             {name: "id"},
             {name: "name"},
             {name: "description"},
             {name: "createdOn"},
             {name: "createdBy"},
             {name: "creationMethod"},
             {name: "appliedOn"},
             {name: "appliedBy"}
           ]
          }
        ]
      end
    },

    revisions: {
      fields: lambda do
        [
          {name: "meta",
           type: "object",
           properties: [
             {name: "paging",
              type: "object",
              properties: [
                {name: "currentPageSize", type: "integer"},
                {name: "offset", type: "integer"},
                {name: "totalSize", type: "integer"}
              ]},
             {name: "schema"}
           ]
          },
          { name: "status",
            type: "object",
            properties: [
              {name: "code", type: "integer"},
              {name: "message"}
            ]},
          {name: "revisions",
           type: "array",
           of: "object",
           properties: [
             {name: "id"},
             {name: "name"},
             {name: "description"},
             {name: "createdOn"},
             {name: "createdBy"},
             {name: "creationMethod"},
             {name: "appliedOn"},
             {name: "appliedBy"}
           ]
          }
        ]
      end
    },

    appliedToModels: {
      fields: lambda do
        [
          {name: "meta",
           type: "object",
           properties: [
             {name: "schema"}
           ]
          },
          { name: "status",
            type: "object",
            properties: [
              {name: "code", type: "integer"},
              {name: "message"}
            ]},
          {name: "appliedToModels",
           type: "array",
           of: "object",
           properties: [
             {name: "modelId"},
             {name: "modelName"},
             {name: "workspaceId"},
             {name: "appliedBy"},
             {name: "appliedOn"},
             {name: "appliedMethod"},
             {name: "modelDeleted", type: :boolean}
           ]
          }
        ]
      end
    },

    sync_task: {
      fields: lambda do
        [
          {name: "meta",
           type: "object",
           properties: [
             name: "schema"
           ]},
          {name: "status",
           type: "object",
           properties: [
             {name: "code", type: "integer"},
             {name: "message"}
           ]},
          {name: "task",
           type: "object",
           properties: [
             {name: "taskId"},
             {name: "taskUrl"},
             {name: "taskState"},
             {name: "currentStep"},
             {name: "result",
              type: "object",
              properties: [
                {name: "successful", type: :boolean}
              ]
             },
             {name: "creationTime"}
           ]
          }
        ]
      end
    },

    views: {
      fields: lambda do
        [
          {name: "meta",
           type: "object",
           properties: [
             {name: "paging",
              type: "object",
              properties: [
                {name: "currentPageSize", type: "integer"},
                {name: "offset", type: "integer"},
                {name: "totalSize", type: "integer"}
              ]},
             {name: "schema"}
           ]
          },
          { name: "status",
            type: "object",
            properties: [
              {name: "code", type: "integer"},
              {name: "message"}
            ]},
          {name: "views",
           type: "array",
           of: "object",
           properties: [
             {name: "code"},
             {name: "id"},
             {name: "name"},
             {name: "moduleId"}
           ]
          }
        ]
      end
    },

    dimensions: {
      fields: lambda do
        [
          {name: "meta",
           type: "object",
           properties: [
             {name: "schema"}
           ]
          },
          { name: "status",
            type: "object",
            properties: [
              {name: "code", type: "integer"},
              {name: "message"}
            ]
          },
          { name: "viewName"},
          { name: "viewId"},
          { name: "columns",
            type: "array",
            of: "object",
            properties: [
              {name: "id"},
              {name: "name"}
            ]
          },
          {name: "rows",
           type: "array",
           of: "object",
           properties: [
             {name: "id"},
             {name: "name"}
           ]
          },
          {name: "pages",
           type: "array",
           of: "object",
           properties: [
             {name: "id"},
             {name: "name"}
           ]
          }
        ]
      end
    },

    dimension_items: {
      fields: lambda do
        [
          {name: "meta",
           type: "object",
           properties: [
             {name: "schema"}
           ]
          },
          { name: "status",
            type: "object",
            properties: [
              {name: "code", type: "integer"},
              {name: "message"}
            ]
          },
          { name: "items",
            type: "array",
            of: "object",
            properties: [
              {name: "id"},
              {name: "name"}
            ]
          }
        ]
      end
    },

    list_items: {
      fields: lambda do
        [
          {name: "meta",
           type: "object",
           properties: [
             {name: "schema"}
           ]
          },
          { name: "status",
            type: "object",
            properties: [
              {name: "code", type: "integer"},
              {name: "message"}
            ]},
          {name: "listItems",
           type: "array",
           of: "object",
           properties: [
             {name: "id"},
             {name: "name"},
             {name: "code"},
             {name: "parent"},
             {name: "parenId"},
             {name: "subsets",
              type: "array",
              of: "object",
              properties: [
                {name: "subsetName"},
                {name: "inSubset", type: :Boolean}
              ]},
             {name: "properties",
              type: "array",
              of: "object",
              properties: [

              ]}
           ]
          }
        ]
      end
    },

    write_cell_data_response: {
      fields: lambda do
        [
          {name: "meta",
           type: "object",
           properties: [
             {name: "schema"}
           ]
          },
          { name: "status",
            type: "object",
            properties: [
              {name: "code", type: "integer"},
              {name: "message"}
            ]},
          {name: "numberOfCellsChanged", type: "integer"},
          {name: "failures",
           type: "array",
           of: "object",
           properties: [
             {name: "requestIndex", type: "integer"},
             {name: "failureType"},
             {name: "failureMessageDetails"}
           ]
          }
        ]
      end
    },

    workspace_id_input: {
      fields: lambda do
        [
          {
            name: "workspace_id",
            control_type: "select",
            pick_list: "workspace_list",
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "workspace_id",
              label: "Workspace ID",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Workspace ID"
            }
          }
        ]
      end
    },

    add_list_items: {
      fields: lambda do
        [
          {
            name: "items",
            type: "array",
            of: "object",
            properties: [
              {name: "name"},
              {name: "code"},
              {name: "parent"},
              {name: "properties",
               type: "object",
               properties: [
                 {name: "p-text"}
               ]
              },
              {name: "subsets",
               type: "object",
               properties: [
                 {name: "subset_one", type: "Boolean"}
               ]
              }
            ]
          }
        ]
      end
    }

    #end object_definitions
  },

  actions: {
    get_workspaces: {

      title: "Get Workspaces",
      subtitle: "Get a list of all workspaces for the user's default tenant",
      description: "Get <span class='provider'>Workspaces</span> " \
        "from <span class='provider'>Anaplan</span>",
      help: "This action retrieves workspaces from Anaplan. Use this action" \
        " to search for accessible workspaces in your Anaplan Tenant",

      input_fields: lambda do |object_definitions|

      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        get("/2/0/workspaces?tenantDetails=true")
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["workspaces"]
      end,

      sample_output: lambda do |_connection, _input|
        #get("/api/v1/users/me/event_types?include=owner")
        #  .params(per_page: 1) || []
      end
    },

    get_workspace_details: {

      title: "Get Workspace details by ID",
      subtitle: "Return Workspace details",
      description: "Get <span class='provider'>Workspace</span> " \
        "by ID from <span class='provider'>Anaplan</span>",
      help: "This action retrieves a specific Workspace and its details from Anaplan. Use this action" \
        " to search for additional workspace details for a given Workspace ID in your Anaplan Tenant",

      input_fields: lambda do |object_definitions|
        {
          name: "workspace",
          control_type: "select",
          pick_list: "workspace_list",
          optional: false,
          toggle_hint: "Select from list",
          toggle_field: {
            name: "workspace",
            label: "Workspace ID",
            type: :string,
            control_type: "text",
            optional: false,
            toggle_hint: "Use Workspace ID"
          }

        }
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        get("/2/0/workspaces/#{_input["workspace"]}?tenantDetails=true")
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["workspace"]
      end,

      sample_output: lambda do |_connection, _input|
        #get("/api/v1/users/me/event_types?include=owner")
        #  .params(per_page: 1) || []
      end
    },

    get_models: {

      title: "Get Models",
      subtitle: "Get a list of all models for a given workspace",
      description: "Get <span class='provider'>Models</span> " \
        "from <span class='provider'>Anaplan</span>",
      help: "This action retrieves Models from Anaplan. Use this action" \
        " to search for accessible Models for a given Workspace in your Anaplan Tenant",

      input_fields: lambda do |object_definitions|
        {
          name: "workspace",
          control_type: "select",
          pick_list: "workspace_list",
          optional: false,
          toggle_hint: "Select from list",
          toggle_field: {
            name: "workspace",
            label: "Workspace ID",
            type: :string,
            control_type: "text",
            optional: false,
            toggle_hint: "Use Workspace ID"
          }
        }
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        get("/2/0/workspaces/#{_input["workspace"]}/models")
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["models"]
      end,

      sample_output: lambda do |_connection, _input|
        #get("/api/v1/users/me/event_types?include=owner")
        #  .params(per_page: 1) || []
      end
    },

    get_model_details: {

      title: "Get Model details by ID",
      subtitle: "Return Model details",
      description: "Get <span class='provider'>Model</span> " \
        "by ID from <span class='provider'>Anaplan</span>",
      help: "This action retrieves a specific Model and its details from Anaplan. Use this action" \
        " to search for additional Model details for a given Model ID in your Anaplan Tenant",

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'workspace_id',
            label: 'Workspace',
            control_type: 'select',
            pick_list: 'workspace_list',
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "workspace_id",
              label: "Workspace ID",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Workspace ID"
            }
          },
          #need to add the option to choose just a model id text input to be passed in from a prior action in a recipe
          {
            name: 'model_id',
            label: 'Model',
            control_type: 'select',
            pick_list: 'model_list',
            pick_list_params: { workspace_id: 'workspace_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'model_id',
              label: 'Model',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Model ID"
            }
          }
        ]
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        #get("https://api.anaplan.com/2/0/workspaces/#{_input["workspace_id"]}/models/#{_input["model_id"]}")
        get("/2/0/models/#{_input["model_id"]}")
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["model"]
      end,

      sample_output: lambda do |_connection, _input|
        #get("/api/v1/users/me/event_types?include=owner")
        #  .params(per_page: 1) || []
      end
    },

    get_imports: {

      title: "Get Imports",
      subtitle: "Get a list of all Imports for a given Model",
      description: "Get <span class='provider'>Imports</span> " \
        "from <span class='provider'>Anaplan</span>",
      help: "This action retrieves Imports from Anaplan. Use this action" \
        " to search for Imports for a given Model",

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'workspace_id',
            label: 'Workspace',
            control_type: 'select',
            pick_list: 'workspace_list',
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "workspace_id",
              label: "Workspace ID",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Workspace ID"
            }
          },
          #need to add the option to choose just a model id text input to be passed in from a prior action in a recipe
          {
            name: 'model_id',
            label: 'Model',
            control_type: 'select',
            pick_list: 'model_list',
            pick_list_params: { workspace_id: 'workspace_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'model_id',
              label: 'Model',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Model ID"
            }
          }

        ]
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        #if _input["include_metadata"]
        get("/2/0/workspaces/#{_input["workspace_id"]}/models/#{_input["model_id"]}/imports")
      end,

      output_fields: lambda do |object_definitions, _input|
        object_definitions["imports"]
      end,

      sample_output: lambda do |_connection, _input|
        #get("/api/v1/users/me/event_types?include=owner")
        #  .params(per_page: 1) || []
      end
    },

    get_importMetadata: {

      title: "Get Import Metadata",
      subtitle: "Get metadata of an Import for a given Model",
      description: "Get <span class='provider'>Import Metadata</span> " \
        "from <span class='provider'>Anaplan</span>",
      help: "This action retrieves Import Metdata from Anaplan. Use this action" \
        " to search for Import Metadata for a given import",

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'workspace_id',
            label: 'Workspace',
            control_type: 'select',
            pick_list: 'workspace_list',
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "workspace_id",
              label: "Workspace ID",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Workspace ID"
            }
          },
          {
            name: 'model_id',
            label: 'Model',
            control_type: 'select',
            pick_list: 'model_list',
            pick_list_params: { workspace_id: 'workspace_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'model_id',
              label: 'Model',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Model ID"
            }
          },
          {
            name: 'import_id',
            label: 'Export',
            control_type: 'select',
            pick_list: 'import_list',
            pick_list_params: { workspace_id: 'workspace_id', model_id: 'model_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'import_id',
              label: 'Import ID',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Import ID"
            }
          }

        ]
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        #if _input["include_metadata"]
        get("/2/0/workspaces/#{_input["workspace_id"]}/models/#{_input["model_id"]}/imports/#{_input["import_id"]}")
      end,

      output_fields: lambda do |object_definitions, _input|
        object_definitions["importMetadata"]
      end,

      sample_output: lambda do |_connection, _input|
        #get("/api/v1/users/me/event_types?include=owner")
        #  .params(per_page: 1) || []
      end
    },

    get_exports: {

      title: "Get Exports",
      subtitle: "Get a list of all Exports for a given Model",
      description: "Get <span class='provider'>Exports</span> " \
        "from <span class='provider'>Anaplan</span>",
      help: "This action retrieves Exports from Anaplan. Use this action" \
        " to search for Exports for a given Model",

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'workspace_id',
            label: 'Workspace',
            control_type: 'select',
            pick_list: 'workspace_list',
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "workspace_id",
              label: "Workspace ID",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Workspace ID"
            }
          },
          {
            name: 'model_id',
            label: 'Model',
            control_type: 'select',
            pick_list: 'model_list',
            pick_list_params: { workspace_id: 'workspace_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'model_id',
              label: 'Model',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Model ID"
            }
          }

        ]
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        #if _input["include_metadata"]
        get("/2/0/workspaces/#{_input["workspace_id"]}/models/#{_input["model_id"]}/exports")
      end,

      output_fields: lambda do |object_definitions, _input|
        object_definitions["exports"]
      end,

      sample_output: lambda do |_connection, _input|
        #get("/api/v1/users/me/event_types?include=owner")
        #  .params(per_page: 1) || []
      end
    },

    get_exportMetadata: {

      title: "Get Export Metadata",
      subtitle: "Get metadata of an Export for a given Model",
      description: "Get <span class='provider'>Export Metadata</span> " \
        "from <span class='provider'>Anaplan</span>",
      help: "This action retrieves Export Metdata from Anaplan. Use this action" \
        " to search for Export Metadata for a given Model",

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'workspace_id',
            label: 'Workspace',
            control_type: 'select',
            pick_list: 'workspace_list',
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "workspace_id",
              label: "Workspace ID",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Workspace ID"
            }
          },
          {
            name: 'model_id',
            label: 'Model',
            control_type: 'select',
            pick_list: 'model_list',
            pick_list_params: { workspace_id: 'workspace_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'model_id',
              label: 'Model',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Model ID"
            }
          },
          {
            name: 'export_id',
            label: 'Export',
            control_type: 'select',
            pick_list: 'export_list',
            pick_list_params: { workspace_id: 'workspace_id', model_id: 'model_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'export_id',
              label: 'Export ID',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Export ID"
            }
          }

        ]
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        #if _input["include_metadata"]
        get("/2/0/workspaces/#{_input["workspace_id"]}/models/#{_input["model_id"]}/exports/#{_input["export_id"]}")
      end,

      output_fields: lambda do |object_definitions, _input|
        object_definitions["exportMetadata"]
      end,

      sample_output: lambda do |_connection, _input|
        #get("/api/v1/users/me/event_types?include=owner")
        #  .params(per_page: 1) || []
      end
    },

    get_exports_metadata: {

      title: "Get Exports Metadata",
      subtitle: "Get metadata of all Exports for a given Model",
      description: "Get <span class='provider'>Exports Metadata</span> " \
        "from <span class='provider'>Anaplan</span>",
      help: "This action retrieves Export Metdata for all Exports from Anaplan. Use this action" \
        " to search for Export Metadata for a given Model",

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'workspace_id',
            label: 'Workspace',
            control_type: 'select',
            pick_list: 'workspace_list',
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "workspace_id",
              label: "Workspace ID",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Workspace ID"
            }
          },
          #need to add the option to choose just a model id text input to be passed in from a prior action in a recipe
          {
            name: 'model_id',
            label: 'Model',
            control_type: 'select',
            pick_list: 'model_list',
            pick_list_params: { workspace_id: 'workspace_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'model_id',
              label: 'Model',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Model ID"
            }
          }

        ]
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        #if _input["include_metadata"]
        #listArray = [{id: "id", name: "name"}, {id: "id1", name: "name1"}]
        #h = Hash[get("https://api.anaplan.com/2/0/workspaces/#{_input["workspace_id"]}/models/#{_input["model_id"]}/lists")['lists'].each{|i| get("https://api.anaplan.com/2/0/workspaces/#{_input["workspace_id"]}/models/#{_input["model_id"]}/lists/#{i["id"]}")['metadata']}.to_a]
        h = Hash[]
        arr = Array[]
        #get("https://api.anaplan.com/2/0/workspaces/#{_input["workspace_id"]}/models/#{_input["model_id"]}/lists")['lists'].each{|i| h[i] = get("https://api.anaplan.com/2/0/workspaces/#{_input["workspace_id"]}/models/#{_input["model_id"]}/lists/#{i["id"]}")['metadata']}
        #x = get("https://api.anaplan.com/2/0/workspaces/#{_input["workspace_id"]}/models/#{_input["model_id"]}/lists")['lists'].each{|i| arr.push(get("https://api.anaplan.com/2/0/workspaces/#{_input["workspace_id"]}/models/#{_input["model_id"]}/lists/#{i["id"]}")['metadata'].to_json)}
        get("/2/0/workspaces/#{_input["workspace_id"]}/models/#{_input["model_id"]}/exports")['exports'].each{
          |i| x=get("/2/0/workspaces/#{_input["workspace_id"]}/models/#{_input["model_id"]}/exports/#{i["id"]}")['exportMetadata']
          x['id'] = "#{i["id"]}"
          x['name'] = "#{i["name"]}"
          x['exportType'] = "#{i["exportType"]}"
          x['exportFormat'] = "#{i["exportFormat"]}"
          x['encoding'] = "#{i["encoding"]}"
          x['layout'] = "#{i["layout"]}"
          arr.push(x)
        }
        {
          exports: arr
        }
        #listArray.each_slice(1).to_a]

      end,

      output_fields: lambda do |object_definitions, _input|
        object_definitions["exports_metadata"]
      end,

      sample_output: lambda do |_connection, _input|
        #get("/api/v1/users/me/event_types?include=owner")
        #  .params(per_page: 1) || []
      end
    },

    get_processes: {

      title: "Get Processes",
      subtitle: "Get a list of all Processes for a given Model",
      description: "Get <span class='provider'>Processes</span> " \
        "from <span class='provider'>Anaplan</span>",
      help: "This action retrieves Processes from Anaplan. Use this action" \
        " to search for Processes for a given Model",

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'workspace_id',
            label: 'Workspace',
            control_type: 'select',
            pick_list: 'workspace_list',
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "workspace_id",
              label: "Workspace ID",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Workspace ID"
            }
          },
          #need to add the option to choose just a model id text input to be passed in from a prior action in a recipe
          {
            name: 'model_id',
            label: 'Model',
            control_type: 'select',
            pick_list: 'model_list',
            pick_list_params: { workspace_id: 'workspace_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'model_id',
              label: 'Model',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Model ID"
            }
          }

        ]
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        #if _input["include_metadata"]
        get("/2/0/workspaces/#{_input["workspace_id"]}/models/#{_input["model_id"]}/processes")
      end,

      output_fields: lambda do |object_definitions, _input|
        #object_definitions["imports"]
      end,

      sample_output: lambda do |_connection, _input|
        #get("/api/v1/users/me/event_types?include=owner")
        #  .params(per_page: 1) || []
      end
    },

    get_processes_metadata: {

      title: "Get Processes Metadata",
      subtitle: "Get metadata of all Processes for a given Model",
      description: "Get <span class='provider'>Processes Metadata</span> " \
        "from <span class='provider'>Anaplan</span>",
      help: "This action retrieves Process Metdata for all Processes from Anaplan. Use this action" \
        " to search for Process Metadata for a given Model",

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'workspace_id',
            label: 'Workspace',
            control_type: 'select',
            pick_list: 'workspace_list',
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "workspace_id",
              label: "Workspace ID",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Workspace ID"
            }
          },
          #need to add the option to choose just a model id text input to be passed in from a prior action in a recipe
          {
            name: 'model_id',
            label: 'Model',
            control_type: 'select',
            pick_list: 'model_list',
            pick_list_params: { workspace_id: 'workspace_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'model_id',
              label: 'Model',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Model ID"
            }
          }

        ]
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        h = Hash[]
        arr = Array[]
        get("/2/0/workspaces/#{_input["workspace_id"]}/models/#{_input["model_id"]}/processes")['processes'].each{
          |i| x=get("/2/0/workspaces/#{_input["workspace_id"]}/models/#{_input["model_id"]}/processes/#{i["id"]}?showImportDataSource=true")['processMetadata']
          x['id'] = "#{i["id"]}"
          arr.push(x)
        }
        {
          processes: arr
        }
        #listArray.each_slice(1).to_a]

      end,

      output_fields: lambda do |object_definitions, _input|
        object_definitions["processes_metadata"]
      end,

      sample_output: lambda do |_connection, _input|
        #get("/api/v1/users/me/event_types?include=owner")
        #  .params(per_page: 1) || []
      end
    },

    get_files: {

      title: "Get Files",
      subtitle: "Get a list of all Files for a given Model",
      description: "Get <span class='provider'>Files</span> " \
        "from <span class='provider'>Anaplan</span>",
      help: "This action retrieves Files from Anaplan. Use this action" \
        " to search for Files for a given Model",

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'workspace_id',
            label: 'Workspace',
            control_type: 'select',
            pick_list: 'workspace_list',
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "workspace_id",
              label: "Workspace ID",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Workspace ID"
            }
          },
          {
            name: 'model_id',
            label: 'Model',
            control_type: 'select',
            pick_list: 'model_list',
            pick_list_params: { workspace_id: 'workspace_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'model_id',
              label: 'Model',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Model ID"
            }
          }

        ]
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        #if _input["include_metadata"]
        get("/2/0/workspaces/#{_input["workspace_id"]}/models/#{_input["model_id"]}/files")
      end,

      output_fields: lambda do |object_definitions, _input|
        object_definitions["files"]
      end,

      sample_output: lambda do |_connection, _input|
        #get("/api/v1/users/me/event_types?include=owner")
        #  .params(per_page: 1) || []
      end
    },

    get_line_items: {

      title: "Get Line Items",
      subtitle: "Get a list of all Line Items for a given Model",
      description: "Get <span class='provider'>LineItems</span> " \
        "from <span class='provider'>Anaplan</span>",
      help: "This action retrieves LineItems from Anaplan. Use this action" \
        " to search for LineItems for a given Model",

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'workspace_id',
            label: 'Workspace',
            control_type: 'select',
            pick_list: 'workspace_list',
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "workspace_id",
              label: "Workspace ID",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Workspace ID"
            }
          },
          #need to add the option to choose just a model id text input to be passed in from a prior action in a recipe
          {
            name: 'model_id',
            label: 'Model',
            control_type: 'select',
            pick_list: 'model_list',
            pick_list_params: { workspace_id: 'workspace_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'model_id',
              label: 'Model',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Model ID"
            }
          },
          {
            name: 'include_metadata',
            label: 'Include Metadata?',
            control_type: 'checkbox',
            optional: false,
            default: true
          }

        ]
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        #if _input["include_metadata"]
        get("/2/0/models/#{_input["model_id"]}/lineItems?includeAll=#{_input["include_metadata"]}")
      end,

      output_fields: lambda do |object_definitions, _input|
        if _input["include_metadata"].is_true?
          object_definitions["lineItemsSimple"]
        else
          object_definitions["lineItemsDetailed"]
        end
      end,

      sample_output: lambda do |_connection, _input|
        #get("/api/v1/users/me/event_types?include=owner")
        #  .params(per_page: 1) || []
      end
    },

    get_modules: {

      title: "Get Modules",
      subtitle: "Get a list of all Modules for a given Model",
      description: "Get <span class='provider'>Modules</span> " \
        "from <span class='provider'>Anaplan</span>",
      help: "This action retrieves Modules from Anaplan. Use this action" \
        " to search for Modules for a given Model",

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'workspace_id',
            label: 'Workspace',
            control_type: 'select',
            pick_list: 'workspace_list',
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "workspace_id",
              label: "Workspace ID",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Workspace ID"
            }
          },
          #need to add the option to choose just a model id text input to be passed in from a prior action in a recipe
          {
            name: 'model_id',
            label: 'Model',
            control_type: 'select',
            pick_list: 'model_list',
            pick_list_params: { workspace_id: 'workspace_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'model_id',
              label: 'Model',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Model ID"
            }
          }

        ]
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        #if _input["include_metadata"]
        get("/2/0/models/#{_input["model_id"]}/modules")
      end,

      output_fields: lambda do |object_definitions, _input|
        object_definitions["modules"]
      end,

      sample_output: lambda do |_connection, _input|
        #get("/api/v1/users/me/event_types?include=owner")
        #  .params(per_page: 1) || []
      end
    },

    get_module_lineitems: {

      title: "Get Module LineItems",
      subtitle: "Get a list of all LineItems in a given Module",
      description: "Get <span class='provider'>Module LineItems</span> " \
        "from <span class='provider'>Anaplan</span>",
      help: "This action retrieves Module LineItems from Anaplan. Use this action" \
        " to search for LineItems in a given Module",

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'workspace_id',
            label: 'Workspace',
            control_type: 'select',
            pick_list: 'workspace_list',
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "workspace_id",
              label: "Workspace ID",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Workspace ID"
            }
          },
          #need to add the option to choose just a model id text input to be passed in from a prior action in a recipe
          {
            name: 'model_id',
            label: 'Model',
            control_type: 'select',
            pick_list: 'model_list',
            pick_list_params: { workspace_id: 'workspace_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'model_id',
              label: 'Model',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Model ID"
            }
          },
          {
            name: 'module_id',
            label: 'Module',
            control_type: 'select',
            pick_list: "module_list",
            pick_list_params: { workspace_id: 'workspace_id', model_id: 'model_id' },
            optional: false
          },
          {
            name: 'include_metadata',
            label: 'Include Metadata?',
            control_type: 'checkbox',
            optional: false,
            default: true
          }


        ]
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        #if _input["include_metadata"]
        get("/2/0/models/#{_input["model_id"]}/modules/#{_input["module_id"]}/lineItems?includeAll=#{_input["include_metadata"]}")
      end,

      output_fields: lambda do |object_definitions, _input|
        if _input["include_metadata"].is_true?
          object_definitions["lineItemsSimple"]
        else
          object_definitions["lineItemsDetailed"]
        end
      end,

      sample_output: lambda do |_connection, _input|
        #get("/api/v1/users/me/event_types?include=owner")
        #  .params(per_page: 1) || []
      end
    },

    get_lists: {

      title: "Get Lists",
      subtitle: "Get a list of all Lists for a given Model",
      description: "Get <span class='provider'>Lists</span> " \
        "from <span class='provider'>Anaplan</span>",
      help: "This action retrieves Lists from Anaplan. Use this action" \
        " to search for Lists for a given Model",

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'workspace_id',
            label: 'Workspace',
            control_type: 'select',
            pick_list: 'workspace_list',
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "workspace_id",
              label: "Workspace ID",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Workspace ID"
            }
          },
          #need to add the option to choose just a model id text input to be passed in from a prior action in a recipe
          {
            name: 'model_id',
            label: 'Model',
            control_type: 'select',
            pick_list: 'model_list',
            pick_list_params: { workspace_id: 'workspace_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'model_id',
              label: 'Model',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Model ID"
            }
          }

        ]
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        #if _input["include_metadata"]
        get("/2/0/workspaces/#{_input["workspace_id"]}/models/#{_input["model_id"]}/lists")
      end,

      output_fields: lambda do |object_definitions, _input|
        object_definitions["lists"]
      end,

      sample_output: lambda do |_connection, _input|
        #get("/api/v1/users/me/event_types?include=owner")
        #  .params(per_page: 1) || []
      end
    },

    get_lists_metadata: {

      title: "Get Lists Metadata",
      subtitle: "Get a list of all Lists for a given Model",
      description: "Get <span class='provider'>Lists Metadata</span> " \
        "from <span class='provider'>Anaplan</span>",
      help: "This action retrieves Lists from Anaplan. Use this action" \
        " to search for Lists for a given Model",

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'workspace_id',
            label: 'Workspace',
            control_type: 'select',
            pick_list: 'workspace_list',
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "workspace_id",
              label: "Workspace ID",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Workspace ID"
            }
          },
          #need to add the option to choose just a model id text input to be passed in from a prior action in a recipe
          {
            name: 'model_id',
            label: 'Model',
            control_type: 'select',
            pick_list: 'model_list',
            pick_list_params: { workspace_id: 'workspace_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'model_id',
              label: 'Model',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Model ID"
            }
          }

        ]
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        #if _input["include_metadata"]
        #listArray = [{id: "id", name: "name"}, {id: "id1", name: "name1"}]
        #h = Hash[get("https://api.anaplan.com/2/0/workspaces/#{_input["workspace_id"]}/models/#{_input["model_id"]}/lists")['lists'].each{|i| get("https://api.anaplan.com/2/0/workspaces/#{_input["workspace_id"]}/models/#{_input["model_id"]}/lists/#{i["id"]}")['metadata']}.to_a]
        h = Hash[]
        arr = Array[]
        #get("https://api.anaplan.com/2/0/workspaces/#{_input["workspace_id"]}/models/#{_input["model_id"]}/lists")['lists'].each{|i| h[i] = get("https://api.anaplan.com/2/0/workspaces/#{_input["workspace_id"]}/models/#{_input["model_id"]}/lists/#{i["id"]}")['metadata']}
        #x = get("https://api.anaplan.com/2/0/workspaces/#{_input["workspace_id"]}/models/#{_input["model_id"]}/lists")['lists'].each{|i| arr.push(get("https://api.anaplan.com/2/0/workspaces/#{_input["workspace_id"]}/models/#{_input["model_id"]}/lists/#{i["id"]}")['metadata'].to_json)}
        get("/2/0/workspaces/#{_input["workspace_id"]}/models/#{_input["model_id"]}/lists")['lists'].each{|i| arr.push(get("/2/0/workspaces/#{_input["workspace_id"]}/models/#{_input["model_id"]}/lists/#{i["id"]}")['metadata'])}
        {
          lists: arr
        }
        #listArray.each_slice(1).to_a]

      end,

      output_fields: lambda do |object_definitions, _input|
        object_definitions["lists_metadata"]
      end,

      sample_output: lambda do |_connection, _input|
        #get("/api/v1/users/me/event_types?include=owner")
        #  .params(per_page: 1) || []
      end
    },

    get_cloudworks_connections: {

      title: "Get CloudWorks Connections",
      subtitle: "Get a list of all CloudWorks Connections",
      description: "Get <span class='provider'>CloudWorks Connections</span> " \
        "from <span class='provider'>Anaplan</span>",
      help: "This action retrieves CloudWorks Connections from Anaplan. Use this action" \
        " to search for CloudWorks Connections",

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        #if _input["include_metadata"]
        get("https://api.cloudworks.anaplan.com/2/0/integrations/connections")
      end,

      output_fields: lambda do |object_definitions, _input|
        #object_definitions["imports"]
      end,

      sample_output: lambda do |_connection, _input|
        #get("/api/v1/users/me/event_types?include=owner")
        #  .params(per_page: 1) || []
      end
    },

    get_cloudworks_integrations: {

      title: "Get CloudWorks Integrations",
      subtitle: "Get a list of all CloudWorks Integrations",
      description: "Get <span class='provider'>CloudWorks Integrations</span> " \
        "from <span class='provider'>Anaplan</span>",
      help: "This action retrieves CloudWorks Integrations from Anaplan. Use this action" \
        " to search for CloudWorks Integrations",

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        #if _input["include_metadata"]
        get("https://api.cloudworks.anaplan.com/2/0/integrations")
      end,

      output_fields: lambda do |object_definitions, _input|
        #object_definitions["imports"]
      end,

      sample_output: lambda do |_connection, _input|
        #get("/api/v1/users/me/event_types?include=owner")
        #  .params(per_page: 1) || []
      end
    },

    create_revision_tag: {

      title: "Create Model Revision",
      subtitle: "Create a revision tag for a given model",
      description: "Create <span class='provider'>Revision Tag</span> " \
        "for a <span class='provider'>Model</span>",
      help: "This action creates a revision tag for a given model. Use this action" \
        " to create a revision tag before syncing the revision to a target model",

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'workspace_id',
            label: 'Workspace',
            control_type: 'select',
            pick_list: 'workspace_list',
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "workspace_id",
              label: "Workspace ID",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Workspace ID"
            }
          },
          #need to add the option to choose just a model id text input to be passed in from a prior action in a recipe
          {
            name: 'model_id',
            label: 'Model',
            control_type: 'select',
            pick_list: 'model_list',
            pick_list_params: { workspace_id: 'workspace_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'model_id',
              label: 'Model',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Model ID"
            }
          },
          {
            name: "revisionName",
            label: "Revision Name",
            optional: false
          },
          {
            name: "revisionDescription",
            label: "Revision Description",
            optional: false
          }



        ]
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        #if _input["include_metadata"]
        body = {
          name: _input["revisionName"],
          description: _input["revisionDescription"]
        }
        post("/2/0/models/#{_input["model_id"]}/alm/revisions", body)
      end,

      output_fields: lambda do |object_definitions, _input|
        object_definitions["revision"]
      end,

      sample_output: lambda do |_connection, _input|
        #get("/api/v1/users/me/event_types?include=owner")
        #  .params(per_page: 1) || []
      end
    },

    get_revisions: {

      title: "Get Revisions in a Model",
      subtitle: "Get revisions for a given model",
      description: "Get <span class='provider'>Revisions</span> " \
        "for a <span class='provider'>Model</span>",
      help: "This action gets revisions for a given model. Use this action" \
        " to get revision tags before syncing the revision to a target model",

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'workspace_id',
            label: 'Source Workspace',
            control_type: 'select',
            pick_list: 'workspace_list',
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "workspace_id",
              label: "Source Workspace ID",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Workspace ID"
            }
          },
          #need to add the option to choose just a model id text input to be passed in from a prior action in a recipe
          {
            name: 'model_id',
            label: 'Source Model',
            control_type: 'select',
            pick_list: 'model_list',
            pick_list_params: { workspace_id: 'workspace_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'model_id',
              label: 'Source Model ID',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Model ID"
            }
          }

        ]
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        #if _input["include_metadata"]
        get("/2/0/models/#{_input["model_id"]}/alm/revisions")
      end,

      output_fields: lambda do |object_definitions, _input|
        object_definitions["revisions"]
      end,

      sample_output: lambda do |_connection, _input|
        #get("/api/v1/users/me/event_types?include=owner")
        #  .params(per_page: 1) || []
      end
    },

    get_models_for_revision: {

      title: "Get Models for a Revision",
      subtitle: "Get models for a given revision",
      description: "Get <span class='provider'>Models</span> " \
        "for a <span class='provider'>Revision</span>",
      help: "This action gets models for a given revision. Use this action" \
        " to get models before syncing the revision to a target model",

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'workspace_id',
            label: 'Source Workspace',
            control_type: 'select',
            pick_list: 'workspace_list',
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "workspace_id",
              label: "Source Workspace ID",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Workspace ID"
            }
          },
          {
            name: 'model_id',
            label: 'Source Model',
            control_type: 'select',
            pick_list: 'model_list',
            pick_list_params: { workspace_id: 'workspace_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'model_id',
              label: 'Source Model ID',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Model ID"
            }
          },
          {
            name: 'revision_id',
            label: 'Revision ID',
            control_type: 'select',
            pick_list: 'revision_list',
            pick_list_params: { model_id: 'model_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'revision_id',
              label: 'Revision ID',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Revision ID"
            }
          }

        ]
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        #if _input["include_metadata"]
        get("/2/0/models/#{_input["model_id"]}/alm/revisions/#{_input["revision_id"]}/appliedToModels")
      end,

      output_fields: lambda do |object_definitions, _input|
        object_definitions["appliedToModels"]
      end,

      sample_output: lambda do |_connection, _input|
        #get("/api/v1/users/me/event_types?include=owner")
        #  .params(per_page: 1) || []
      end
    },

    get_compatible_source_model_revisions: {

      title: "Get Compatible Revisions in a Model",
      subtitle: "Get revisions for a given model",
      description: "Get <span class='provider'>Revisions</span> " \
        "for a <span class='provider'>Model</span>",
      help: "This action gets revisions for a given model. Use this action" \
        " to get revision tags before syncing the revision to a target model",

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'workspace_id',
            label: 'Source Workspace',
            control_type: 'select',
            pick_list: 'workspace_list',
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "workspace_id",
              label: "Source Workspace ID",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Workspace ID"
            }
          },
          #need to add the option to choose just a model id text input to be passed in from a prior action in a recipe
          {
            name: 'model_id',
            label: 'Source Model',
            control_type: 'select',
            pick_list: 'model_list',
            pick_list_params: { workspace_id: 'workspace_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'model_id',
              label: 'Source Model ID',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Model ID"
            }
          },
          {
            name: 'workspace_id_2',
            label: 'Target Workspace',
            control_type: 'select',
            pick_list: 'workspace_list',
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "workspace_id_2",
              label: "Target Workspace ID",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Workspace ID"
            }
          },
          #need to add the option to choose just a model id text input to be passed in from a prior action in a recipe
          {
            name: 'model_id_2',
            label: 'Target Model',
            control_type: 'select',
            pick_list: 'model_list_2',
            pick_list_params: { workspace_id_2: 'workspace_id_2' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'model_id_2',
              label: 'Target Model ID',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Model ID"
            }
          }

        ]
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        #if _input["include_metadata"]
        get("/2/0/models/#{_input["model_id_2"]}/alm/syncableRevisions?sourceModelId=#{_input["model_id"]}")
      end,

      output_fields: lambda do |object_definitions, _input|
        object_definitions["revision"]
      end,

      sample_output: lambda do |_connection, _input|
        #get("/api/v1/users/me/event_types?include=owner")
        #  .params(per_page: 1) || []
      end
    },

    get_latest_revision: {

      title: "Get Latest Revision for a Model",
      subtitle: "Get latest revision for a given model",
      description: "Get <span class='provider'>Latest Revision</span> " \
        "for a <span class='provider'>Model</span>",
      help: "This action gets the latest revision for a given model. Use this action" \
        " to get the latest revision tag before syncing the revision to a target model",

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'workspace_id',
            label: 'Workspace',
            control_type: 'select',
            pick_list: 'workspace_list',
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "workspace_id",
              label: "Workspace ID",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Workspace ID"
            }
          },
          #need to add the option to choose just a model id text input to be passed in from a prior action in a recipe
          {
            name: 'model_id',
            label: 'Model',
            control_type: 'select',
            pick_list: 'model_list',
            pick_list_params: { workspace_id: 'workspace_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'model_id',
              label: 'Model ID',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Model ID"
            }
          }

        ]
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        #if _input["include_metadata"]
        body = { revision: get("/2/0/models/#{_input["model_id"]}/alm/latestRevision")['revisions'][0]}

      end,

      output_fields: lambda do |object_definitions, _input|
        object_definitions["revision_one"]
      end,

      sample_output: lambda do |_connection, _input|
        #get("/api/v1/users/me/event_types?include=owner")
        #  .params(per_page: 1) || []
      end
    },

    create_sync_task: {

      title: "Create Model Sync Task",
      subtitle: "Create a model sync task for a revision",
      description: "Create <span class='provider'>Model Sync Task</span> " \
        "for a <span class='provider'>Revision</span>",
      help: "This action creates a model sync task between two models for a revision. Use this action" \
        " to create a model sync task to sync a revision to a target model",

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'workspace_id',
            label: 'Source Workspace',
            control_type: 'select',
            pick_list: 'workspace_list',
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "workspace_id",
              label: "Source Workspace ID",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Workspace ID"
            }
          },
          {
            name: 'model_id',
            label: 'Source Model',
            control_type: 'select',
            pick_list: 'model_list',
            pick_list_params: { workspace_id: 'workspace_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'model_id',
              label: 'Source Model ID',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Model ID"
            }
          },
          {
            name: 'revision_id',
            label: 'Revision ID',
            control_type: 'select',
            pick_list: 'revision_list',
            pick_list_params: { model_id: 'model_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'revision_id',
              label: 'Revision ID',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Revision ID"
            }
          },

          {
            name: 'workspace_id_2',
            label: 'Target Workspace',
            control_type: 'select',
            pick_list: 'workspace_list',
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "workspace_id_2",
              label: "Target Workspace ID",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Workspace ID"
            }
          },
          {
            name: 'latest_model_id',
            label: 'Target Model',
            control_type: 'select',
            pick_list: 'model_list_2',
            pick_list_params: { workspace_id_2: 'workspace_id_2' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'latest_model_id',
              label: 'Target Model ID',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Model ID"
            }
          },
          {
            name: 'latest_revision_id',
            label: 'Target Revision ID',
            control_type: 'select',
            pick_list: 'latest_revision_list',
            pick_list_params: { latest_model_id: 'latest_model_id' },
            optional: true,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'latest_revision_id',
              label: 'Target Revision ID',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Revision ID"
            }
          }



        ]
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        #if _input["include_metadata"]
        body = {
          sourceRevisionId: _input["revision_id"],
          sourceModelId: _input["model_id"],
          targetRevisionId: _input["latest_revision_id"]
        }
        x = post("/2/0/models/#{_input["latest_model_id"]}/alm/syncTasks", body)
        taskUrl = x['task']['taskUrl']

        while get(taskUrl)['task']['taskState'] != 'COMPLETE'
          x = 1+1
        end

        get(taskUrl)

      end,

      output_fields: lambda do |object_definitions, _input|
        object_definitions["sync_task"]
      end,

      sample_output: lambda do |_connection, _input|
        #get("/api/v1/users/me/event_types?include=owner")
        #  .params(per_page: 1) || []
      end
    },

    get_views: {

      title: "Get Views in a Model",
      subtitle: "Get views for a given model",
      description: "Get <span class='provider'>Views</span> " \
        "for a <span class='provider'>Model</span>",
      help: "This action gets all views for a given model. Use this action" \
        " to get views",

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'workspace_id',
            label: 'Workspace',
            control_type: 'select',
            pick_list: 'workspace_list',
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "workspace_id",
              label: "Workspace ID",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Workspace ID"
            }
          },
          {
            name: 'model_id',
            label: 'Model',
            control_type: 'select',
            pick_list: 'model_list',
            pick_list_params: { workspace_id: 'workspace_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'model_id',
              label: 'Model ID',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Model ID"
            }
          }

        ]
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        #if _input["include_metadata"]
        get("/2/0/workspaces/#{_input["workspace_id"]}/models/#{_input["model_id"]}/views")
      end,

      output_fields: lambda do |object_definitions, _input|
        object_definitions["views"]
      end,

      sample_output: lambda do |_connection, _input|
        #get("/api/v1/users/me/event_types?include=owner")
        #  .params(per_page: 1) || []
      end
    },

    get_dimensions: {

      title: "Get Dimensions in a View",
      subtitle: "Get dimensions for a given view",
      description: "Get <span class='provider'>Dimensions</span> " \
        "for a <span class='provider'>View</span>",
      help: "This action gets all dimensions for a given view. Use this action" \
        " to get dimensions (including Line Item Subsets)",

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'workspace_id',
            label: 'Workspace',
            control_type: 'select',
            pick_list: 'workspace_list',
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "workspace_id",
              label: "Workspace ID",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Workspace ID"
            }
          },
          {
            name: 'model_id',
            label: 'Model',
            control_type: 'select',
            pick_list: 'model_list',
            pick_list_params: { workspace_id: 'workspace_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'model_id',
              label: 'Model ID',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Model ID"
            }
          },
          {
            name: 'view_id',
            label: 'View',
            control_type: 'select',
            pick_list: 'view_list',
            pick_list_params: { workspace_id: 'workspace_id', model_id: 'model_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'view_id',
              label: 'View ID',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use View ID"
            }
          }

        ]
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        #if _input["include_metadata"]
        get("/2/0/workspaces/#{_input["workspace_id"]}/models/#{_input["model_id"]}/views/#{_input["view_id"]}")
      end,

      output_fields: lambda do |object_definitions, _input|
        object_definitions["dimensions"]
      end,

      sample_output: lambda do |_connection, _input|
        #get("/api/v1/users/me/event_types?include=owner")
        #  .params(per_page: 1) || []
      end
    },

    get_dimension_items: {

      title: "Get Dimension Items",
      subtitle: "Get items for a given dimension",
      description: "Get <span class='provider'>Items</span> " \
        "for a <span class='provider'>Dimension</span>",
      help: "This action gets all items for a given dimension. Use this action" \
        " to get items in a dimension (including Line Item Subset items)",

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'workspace_id',
            label: 'Workspace',
            control_type: 'select',
            pick_list: 'workspace_list',
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "workspace_id",
              label: "Workspace ID",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Workspace ID"
            }
          },
          {
            name: 'model_id',
            label: 'Model',
            control_type: 'select',
            pick_list: 'model_list',
            pick_list_params: { workspace_id: 'workspace_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'model_id',
              label: 'Model ID',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Model ID"
            }
          },
          {
            name: 'dimension_id',
            label: 'Dimension ID',
            type: :string,
            control_type: "text",
            optional: false
          }

        ]
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        #if _input["include_metadata"]
        get("/2/0/models/#{_input["model_id"]}/dimensions/#{_input["dimension_id"]}/items")
      end,

      output_fields: lambda do |object_definitions, _input|
        object_definitions["dimension_items"]
      end,

      sample_output: lambda do |_connection, _input|
        #get("/api/v1/users/me/event_types?include=owner")
        #  .params(per_page: 1) || []
      end
    },

    get_list_items: {

      title: "Get List Items",
      subtitle: "Get list items for a given list",
      description: "Get <span class='provider'>List Items</span> " \
        "for a <span class='provider'>List</span>",
      help: "This action gets all list items for a given list. Use this action" \
        " to get list items and to determine subset size",

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'workspace_id',
            label: 'Workspace',
            control_type: 'select',
            pick_list: 'workspace_list',
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "workspace_id",
              label: "Workspace ID",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Workspace ID"
            }
          },
          {
            name: 'model_id',
            label: 'Model',
            control_type: 'select',
            pick_list: 'model_list',
            pick_list_params: { workspace_id: 'workspace_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'model_id',
              label: 'Model ID',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Model ID"
            }
          },
          {
            name: 'list_id',
            label: 'List',
            control_type: 'select',
            pick_list: 'list_list',
            pick_list_params: { workspace_id: 'workspace_id', model_id: 'model_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'list_id',
              label: 'List ID',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use List ID"
            }
          }

        ]
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        #if _input["include_metadata"]
        raw_data = get("/2/0/workspaces/#{_input["workspace_id"]}/models/#{_input["model_id"]}/lists/#{_input["list_id"]}/items?includeAll=true")

        listItems = raw_data['listItems']
        x = {}
        z = {}
        y = {}
        listItems.each do |hash|
          x = hash['subsets']
          #x =
          f = [{}]
          x.each do |hash2|
            #puts "hash: #{hash2}"
            #puts "new hash: {subsetName: \"#{hash2[0]}\", inSubset: #{hash2[1]}}"
            f.push("{subsetName: \"#{hash2[0]}\", inSubset: #{hash2[1]}}")
            #puts "#{hash2} name: #{hash2["name"]}"
            #puts "#{hash2} value: #{hash2["value"]}"
            #  z = hash2.map { |o| {"subsetName": o, "inSubset": o} }
          end
          puts f
          #hash['subsets'] = f

        end
        puts listItems
        puts x
        puts z
        puts y
        #puts z.to_json

        final_body = x


      end,

      output_fields: lambda do |object_definitions, _input|
        object_definitions["list_items"]
      end,

      sample_output: lambda do |_connection, _input|
        #get("/api/v1/users/me/event_types?include=owner")
        #  .params(per_page: 1) || []
      end
    },

    add_list_items: {

      title: "Add List Items",
      subtitle: "Add List Items to a List",
      description: "Add <span class='provider'>List Items</span> " \
        "to a <span class='provider'>List</span>",
      help: "This action adds List Items to a given List. Use this action" \
        " add List Items to an existing List",

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'workspace_id',
            label: 'Workspace',
            control_type: 'select',
            pick_list: 'workspace_list',
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "workspace_id",
              label: "Workspace ID",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Workspace ID"
            }
          },
          {
            name: 'model_id',
            label: 'Model',
            control_type: 'select',
            pick_list: 'model_list',
            pick_list_params: { workspace_id: 'workspace_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'model_id',
              label: 'Model',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Model ID"
            }
          },
          {
            name: 'list_id',
            label: 'List',
            control_type: 'select',
            pick_list: 'list_list',
            pick_list_params: { workspace_id: 'workspace_id' , model_id: 'model_id'},
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'list_id',
              label: 'List',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use List ID"
            }
          },
          {
            name: "items",
            type: "array",
            of: "object",
            optional: false,
            properties: [
              {name: "name"},
              {name: "code", optional: false},
              {name: "parent"},
              {name: "properties",
               type: "object",
               properties: [
                 {name: "p-text"}
               ]
              },
              {name: "subsets",
               type: "object",
               properties: [
                 {name: "subset_one", type: "Boolean"}
               ]
              }
            ]
          }

        ]
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        #if _input["include_metadata"]

        body = {
          "items": _input["items"]
        }

        post("/2/0/workspaces/#{_input["workspace_id"]}/models/#{_input["model_id"]}/lists/#{_input["list_id"]}/items?action=add", body)
      end,

      output_fields: lambda do |object_definitions, _input|
        object_definitions["revision"]
      end,

      sample_output: lambda do |_connection, _input|
        #get("/api/v1/users/me/event_types?include=owner")
        #  .params(per_page: 1) || []
      end
    },

    write_module_cell_data: {

      title: "Write Cell Data",
      subtitle: "Write data to cells in a Module",
      description: "Write <span class='provider'>Cell Data</span> " \
        "to a <span class='provider'>Module</span>",
      help: "This action writes cell data to a Module. Use this action" \
        " to write cell data to a module",

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'workspace_id',
            label: 'Workspace',
            control_type: 'select',
            pick_list: 'workspace_list',
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "workspace_id",
              label: "Workspace ID",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Workspace ID"
            }
          },
          {
            name: 'model_id',
            label: 'Model',
            control_type: 'select',
            pick_list: 'model_list',
            pick_list_params: { workspace_id: 'workspace_id' },
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'model_id',
              label: 'Model',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Model ID"
            }
          },
          {
            name: 'module_id',
            label: 'Module',
            control_type: 'select',
            pick_list: 'module_list',
            pick_list_params: { workspace_id: 'workspace_id' , model_id: 'model_id'},
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: 'module_id',
              label: 'Module',
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Module ID"
            }
          },

          {name: "line_item_id",
           label: "Line Item",
           control_type: 'select',
           pick_list: 'line_item_list',
           pick_list_params: { model_id: 'model_id', module_id: 'module_id'},
           optional: false,
           toggle_hint: "Select from list",
           toggle_field: {
             name: 'line_item_id',
             label: 'Line Item',
             type: :string,
             control_type: "text",
             optional: false,
             toggle_hint: "Use Line Item ID"
           }
          },

          {name: "dimension_id",
           label: "Dimension",
           control_type: 'select',
           pick_list: 'line_item_dimension_list',
           pick_list_params: { model_id: 'model_id', line_item_id: 'line_item_id'},
           optional: false,
           toggle_hint: "Select from list",
           toggle_field: {
             name: 'dimension_id',
             label: 'Dimension',
             type: :string,
             control_type: "text",
             optional: false,
             toggle_hint: "Use Dimension ID"
           }
          },
          {name: "item_id",
           label: "Dimension Item",
           control_type: 'select',
           pick_list: 'dimension_items_list',
           pick_list_params: { model_id: 'model_id', line_item_id: 'line_item_id', dimension_id: 'dimension_id'},
           optional: false,
           toggle_hint: "Select from list",
           toggle_field: {
             name: 'item_id',
             label: 'Dimension Item',
             type: :string,
             control_type: "text",
             optional: false,
             toggle_hint: "Use Dimension Item ID"
           }
          },
          {name: "value",
           label: "Value"}


        ]
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        #if _input["include_metadata"]

        body = [
          {
            "lineItemId": _input["line_item_id"],
            "dimensions": [
              { "dimensionId": _input["dimension_id"], "itemCode": _input["item_id"] }
            ],
            "value": _input["value"]
          }
        ]

        post("/2/0/models/#{_input["model_id"]}/modules/#{_input["module_id"]}/data", body)
      end,

      output_fields: lambda do |object_definitions, _input|
        object_definitions["write_cell_data_response"]
      end,

      sample_output: lambda do |_connection, _input|
        #get("/api/v1/users/me/event_types?include=owner")
        #  .params(per_page: 1) || []
      end
    }

    #end of actions
  },


  pick_lists: {
    # Picklists can be referenced by inputs fields or object_definitions
    # possible arguements - connection
    # see more at https://docs.workato.com/developing-connectors/sdk/sdk-reference/picklists.html
    workspace_list: lambda do |connection|
      get("/2/0/workspaces")["workspaces"].
        map { |workspace| [workspace["name"], workspace["id"]] }
    end,

    model_list: lambda do |connection, workspace_id:|
      get("/2/0/workspaces/#{workspace_id}/models/")["models"].
        map { |model| [model["name"], model["id"]] }
    end,

    model_list_2: lambda do |connection, workspace_id_2:|
      get("/2/0/workspaces/#{workspace_id_2}/models/")["models"].
        map { |model| [model["name"], model["id"]] }
    end,

    module_list: lambda do |connection, workspace_id:, model_id:|
      get("/2/0/workspaces/#{workspace_id}/models/#{model_id}/modules")["modules"].
        map { |a_module| [a_module["name"], a_module["id"]] }
    end,

    list_list: lambda do |connection, workspace_id:, model_id:|
      get("/2/0/workspaces/#{workspace_id}/models/#{model_id}/lists")["lists"].
        map { |list| [list["name"], list["id"]] }
    end,

    line_item_list: lambda do |connection, model_id:, module_id: |
      get("/2/0/models/#{model_id}/modules/#{module_id}/lineItems")["items"].
        map { |a_lineitem| [a_lineitem["name"], a_lineitem["id"]] }
    end,

    line_item_dimension_list: lambda do |connection, model_id:, line_item_id: |
      get("/2/0/models/#{model_id}/lineItems/#{line_item_id}/dimensions")["dimensions"].
        map { |a_dimension| [a_dimension["name"], a_dimension["id"]] }
    end,

    dimension_items_list: lambda do |connection, model_id:, line_item_id:, dimension_id: |
      get("/2/0/models/#{model_id}/lineItems/#{line_item_id}/dimensions/#{dimension_id}/items")["items"].
        map { |a_item| [a_item["name"], a_item["code"]] }
    end,

    revision_list: lambda do |connection, model_id:|
      get("/2/0/models/#{model_id}/alm/revisions")["revisions"].
        map { |revision| [revision["name"], revision["id"]] }
    end,

    latest_revision_list: lambda do |connection, latest_model_id:|
      get("/2/0/models/#{latest_model_id}/alm/latestRevision")["revisions"].
        map { |revision| [revision["name"], revision["id"]] }
    end,

    view_list: lambda do |connection, workspace_id:, model_id:|
      get("/2/0/workspaces/#{workspace_id}/models/#{model_id}/views")["views"].
        map { |view| [view["name"], view["id"]] }
    end,

    module_view_list: lambda do |connection, workspace_id:, model_id:, module_id:|
      get("/2/0/workspaces/#{workspace_id}/models/#{model_id}/modules/#{module_id}/views")["views"].
        map { |view| [view["name"], view["id"]] }
    end,

    export_list: lambda do |connection, workspace_id:, model_id:|
      get("/2/0/workspaces/#{workspace_id}/models/#{model_id}/exports")["exports"].
        map { |export| [export["name"], export["id"]] }
    end,

    import_list: lambda do |connection, workspace_id:, model_id:|
      get("/2/0/workspaces/#{workspace_id}/models/#{model_id}/imports")["imports"].
        map { |import| [import["name"], import["id"]] }
    end

  },

  methods: {
  }
  # More connector code here
}
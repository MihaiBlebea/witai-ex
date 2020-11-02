defmodule Witai do

    alias Witai.Client, as: Client

    @base_url "https://api.wit.ai"

    @version "20201023"

    def message("") do
        {:noreply, %{}}
    end

    @spec message(binary) :: {atom, %{}}
    def message(term) when is_binary(term) do
        %{
            "entities" => entities,
            "intents" => intents,
            "text" => _text,
            "traits" => _traits
        } = Client.get "#{ @base_url }/message?v=#{ @version }&q=#{ Client.encode_message(term) }"

        {
            extract_intent(intents),
            extract_entities(entities)
        }
    end

    defp extract_intent(intents) when is_list(intents) do
        intents
        |> Enum.filter(fn (%{"id" => _, "name" => _name, "confidence" => confidence})-> confidence > 0.5 end)
        |> Enum.at(0)
        |> to_atom
    end

    defp to_atom(%{"id" => _, "name" => name, "confidence" => _}) do
        String.to_existing_atom(name)
    end

    defp to_atom(nil) do
        raise "No valid intent found"
    end

    defp extract_entities(entities) when is_map(entities) do
        entities
        |> Map.values
        |> List.flatten
        |> build_entity_map
    end

    defp build_entity_map(entities) when is_list(entities) do
        build_entity_map(entities, 0, %{})
    end

    defp build_entity_map(entities, index, result) when is_list(entities) and is_integer(index) and is_map(result) do
        case Enum.at(entities, index) do
            nil -> result
            entity ->
                new_result = Map.put(result, Map.get(entity, "name"), Map.get(entity, "value"))
                build_entity_map(entities, index + 1, new_result)
        end
    end

    # Intents

    @spec create_intent(binary) :: map
    def create_intent(name) when is_binary(name) do
        Client.post "#{ @base_url }/intents?v=#{ @version }", %{"name" => name}
    end

    @spec create_intents(list) :: list
    def create_intents(names) when is_list(names) do
        names
        |> Enum.map(fn (name)-> create_intent(name) end)
    end

    @spec delete_intent(binary) :: :ok | :fail
    def delete_intent(name) when is_binary(name) do
        Client.delete "#{ @base_url }/intents/#{ name }?v=#{ @version }"
    end

    @spec get_intent(binary) :: map
    def get_intent(name) when is_binary(name) do
        Client.get "#{ @base_url }/intents/#{ name }?v=#{ @version }"
    end

    # Entities

    @spec get_entities :: list
    def get_entities() do
        Client.get "#{ @base_url }/entities?v=#{ @version }"
    end

    @spec get_entity(binary) :: map
    def get_entity(name) when is_binary(name) do
        Client.get "#{ @base_url }/entities/#{ name }?v=#{ @version }"
    end

    @doc """
    ### Request body:
    ```
    %{
        "name" => "entity_name",
        "roles" => [],
        "lookups" => [
            "free-text",
            "keywords"
        ]
    }
    ```
    """
    @spec create_entity(map) :: map
    def create_entity(req_body) when is_map(req_body) do
        Client.post "#{ @base_url }/entities?v=#{ @version }", req_body
    end

    @spec delete_entity(binary) :: :ok | :fail
    def delete_entity(name) when is_binary(name) do
        Client.delete "#{ @base_url }/entities/#{ name }?v=#{ @version }"
    end

    @spec update_entity(binary, map) :: :ok | :fail
    def update_entity(name, req_body) when is_binary(name) and is_map(req_body) do
        Client.put "#{ @base_url }/entities/#{ name }?v=#{ @version }", req_body
    end

    # Utterances

    @spec get_utterances(integer) :: list
    def get_utterances(limit) do
        Client.get "#{ @base_url }/utterances?v=#{ @version }&limit=#{ to_string(limit) }"
    end

    @spec get_utterances(integer, integer) :: list
    def get_utterances(limit, offset) do
        Client.get "#{ @base_url }/utterances?v=#{ @version }&limit=#{ to_string(limit) }&offset=#{ offset }"
    end

    @spec get_utterances(integer, integer, list) :: list
    def get_utterances(limit, offset, intents) do
        intents_str = Enum.join intents, ","
        Client.get "#{ @base_url }/utterances?v=#{ @version }&limit=#{ to_string(limit) }&offset=#{ offset }&intents=#{ intents_str }"
    end

    @doc """
    ### Request body:
    ```
    [
        %{
            "text" => "I want to buy a bread",
            "intent" => "buy_bread",
            "entities" => [
                %{
                    "entity" => "wit$location:to",
                    "start" => 17,
                    "end" => 20,
                    "body" => "sfo",
                    "entities" => []
                }
            ],
            "traits" => []
        }
    ]
    ```
    """
    @spec create_utterances(list) :: map
    def create_utterances(list) when is_list(list) do
        Client.post "#{ @base_url }/utterances?v=#{ @version }", list
    end

    @doc """
    ### Request body:
    ```
    [
        %{
            "text" => "I want to buy some bread"
        }
    ]
    ```
    """
    @spec delete_utterances(list) :: :ok | :fail
    def delete_utterances(list) when is_list(list) do
        Client.delete "#{ @base_url }/utterances?v=#{ @version }", list
    end
end

using DataFrames
using JSON
using GLM
using Serialization
using Genie

# 1. Load data from the JSON file
data = JSON.parsefile("purchases.json")
df = DataFrame(data)

# 2. Create the model
X = select(df, [:hour, :day])
y = df.purchase

# Split the data into training and testing sets
train_indices = sample(1:nrow(df), round(Int, 0.8 * nrow(df)), replace=false)
X_train = X[train_indices, :]
y_train = y[train_indices]
X_test = X[setdiff(1:nrow(df), train_indices), :]
y_test = y[setdiff(1:nrow(df), train_indices)]

# Fit the logistic regression model
model = glm(@formula(purchase ~ hour + day), DataFrame(X_train, purchase=y_train), Binomial())

# Save the model
open("model.jls", "w") do file
    serialize(file, model)
end

# 3. Deploy the model using Genie
module MyApp
    using Genie, Genie.Router, JSON

    struct Item
        hour::Int
        day::Int
    end

    function predict(item::Item)
        # Load the model
        model = open("model.jls") do file
            deserialize(file)
        end

        # Create a DataFrame for the input
        input_df = DataFrame(hour=[item.hour], day=[item.day])
        
        # Get the predicted probability
        prediction = predict(model, input_df)
        purchase_probability = prediction[1]

        return Dict("purchase_probability" => purchase_probability)
    end

    # Define the route for prediction
    @route POST "/prediction" do
        item = JSON.parse(String(request.body))
        hour = item["hour"]
        day = item["day"]
        result = predict(Item(hour, day))
        json_response(result)
    end
end

# Start the Genie application
Genie.startup()

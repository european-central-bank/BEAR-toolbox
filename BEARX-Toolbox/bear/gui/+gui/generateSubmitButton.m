
function button = generateSubmitButton(options)

    arguments
        options.Text (1, 1) string = "Submit"
    end

    button = "<input style='color:black' style='background-color:gray' type='submit' value='{TEXT}'>";
    button = replace(button, "{TEXT}", options.Text);

end%


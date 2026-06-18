
function area = generateTextArea(topic, text, action)

    arguments
        topic (1, 1) string
        text (1, 1) string
        action (1, 1) string
    end

    submit = gui.generateSubmitButton();

    area = join([
        "<form action='matlab:{ACTION}'>"
        "<textarea name='{TOPIC}' id='{TOPIC}' cols='50' rows='10'>{TEXT}</textarea>"
        "<br/>"
        submit
    ], newline());

    area = replace(area, "{TOPIC}", topic);
    area = replace(area, "{ACTION}", action);
    area = replace(area, "{TEXT}", text);

end%


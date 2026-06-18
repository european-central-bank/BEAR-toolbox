
function form = updateValuesFromSubmission(form, submission)

    for n = textual.fields(form)
        try
            form.(n).value = submission.(n);
        end
    end

end%


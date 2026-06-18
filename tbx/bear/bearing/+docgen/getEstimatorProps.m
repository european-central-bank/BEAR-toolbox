
function out = getEstimatorProps()

    propsDir = docgen.getDirectory("estimator.Tracer");
    files = dir(fullfile(propsDir, "*.m"));
    out = struct();
    propstoIgnore = [ ...
        "SampleCounter","BeenInitialized", "HasCrossUnitVariationInBeta",...
        "HasCrossUnitVariationInSigma", ...
        "Description" ...
    ];
    for i = 1 : numel(files)
        name = extractBefore(files(i).name, ".m");
        cname = "estimator." + name ;
        estimatorMC = meta.class.fromName(cname);
        if  ~isempty(estimatorMC)
            props = struct();
            for i = 1 : numel(estimatorMC.PropertyList)
                prop = estimatorMC.PropertyList(i);
                if prop.Hidden || prop.Constant
                    continue
                end
                % collect default value
                if prop.HasDefault && ~ismember(prop.Name, propstoIgnore)
                    props.(prop.Name) = prop.DefaultValue;
                end
            end
            if ~isempty(fieldnames(props))
                out.(name).props = props;
            end
        end
    end

end%



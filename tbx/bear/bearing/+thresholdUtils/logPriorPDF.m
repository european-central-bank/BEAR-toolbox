function y = logPriorPDF(th, meanThreshold, varThreshold)

    y = largeshockUtils.mvnlpdf(th - meanThreshold, sqrt(varThreshold));

end
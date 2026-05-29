classdef TestTomlWrite < matlab.unittest.TestCase

  methods (Test)

    function testRoundTrip(testCase)
      parent_dir = fileparts(fileparts(mfilename('fullpath')));

      toml_data = toml.read(fullfile(parent_dir, 'example.toml'));

      fname = [tempname, '.toml'];
      toml.write(fname, toml_data);

      testCase.verifyEqual(toml.read(fname), toml_data, ...
       'Did not perform a round-trip read/write sequence correctly.')
    end

  end

end
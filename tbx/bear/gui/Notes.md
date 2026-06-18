
### Technological solution

* HTML based user interface

* Matlab runs an HTTP server behind its web browser

* Allows us to send calculation requests, store results/data in Matlab
  independent files (JSON), and dynamically change the HTML pages

* UI design uses standard (Matlab independent) elements: Markdown, HTML, CSS, and JavaScript


### Single source of truth

* Underlying meta data (e.g. the list of available estimators and their settings)
  is obtained programmatically from the Matlab classes (using Matlab's
  metaclassses)

* This information is extracted and stored as JSON files (Matlab independent
  format)

### Portability

* Extremely easy to port to another language (that supports HTTP servers) if needed or desired


### Dynamic elements

* Interactive HTML forms (text fields, checkboxes, radio buttons, etc.)

* File selection

* External file modifications and edits (e.g. sign or zero restriction tables)

* The actual HTML content rendered in the browser is dynamically generated
  based on the current state of the user information


### Execution

* When all information is entered and stored as JSON, then a simple Matlab
  script is generated to run all the tasks (estimation, identification,
  forecasts, etc.)


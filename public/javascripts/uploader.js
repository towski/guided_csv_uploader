var Cell = function(row, col, value){
  this.initialize({row: row, col: col, value: value})
}

Cell.prototype = {
  row: 0,
  col: 0,
  value: null,
  initialize: function(options){
    this.row = options["row"]
    this.col = options["col"]
    this.value = options["value"]
  }
}

var CSVUploader = function(){
  this.initialize()
}

CSVUploader.prototype = {
  multiple_employees : true,
  cells : [],
  data_finder_cells : {},
  current_step : 0,
  data_finders : ["employee_name", "clocked_in_date", "clocked_in_time", "clocked_out_date", "clocked_out_time"],
  multiple_employees : true,
  colors : ["red", "green", "blue", "orange", "purple"],
  initialize: function(){},
  showDialog: function(string){
    document.querySelector("#dialog").innerHTML = string.replace(/_/g, " ")
    $( "#dialog" ).dialog()
    var dialog = document.querySelector("#dialog").parentNode
    dialog.style.top = 0
  },
  startOverOnClick: function(){
    cells = []
    var table_cells = document.querySelectorAll(".table_cell")
    for(var i = 0; i < table_cells.length ; i++){
      var element = table_cells[i]
      element.style.border = null
      element.clicked = null
    }
    var holder = document.querySelector("#data_finder_inputs")
    holder.innerHTML = ""
    this.current_step = 0
    this.stepDialog()
  },
  detectFinders: function(){
    var local_uploader = this
    var holder = document.querySelector("#data_finder_inputs")
    if(!multiple_employees){
      var employee_name = document.querySelector("#employee_name")
      var cell = this.data_finder_cells["employee_name"]
      employee_name.value = cell.value
    }
    this.data_finders.forEach(function(finder){
      var cell = local_uploader.data_finder_cells[finder]
      if(cell == undefined){
        return false
      }
      var input = document.createElement('input')
      input.type = 'hidden'
      input.name = 'data_finders[][column_number]'
      input.value = cell.col
      holder.appendChild(input)
      input = document.createElement('input')
      input.type = 'hidden'
      input.name = 'data_finders[][starting_row]'
      input.value = cell.row
      holder.appendChild(input)
      input = document.createElement('input')
      input.type = 'hidden'
      input.name = 'data_finders[][data_type]'
      input.value = finder
      holder.appendChild(input)
    })
    return true
  },
  validateFinders: function(){
    var cell = this.data_finder_cells["employee_name"]
    if(cell.value.length == ""){
      this.showDialog("Employee name is length 0, please start over <input type='submit' value='Start Over' onclick='uploader.startOverOnClick();return false'/>")
      return false
    }
    return true
  },
  setMultipleEmployees: function(value){
    multiple_employees = value
    var input = document.querySelector("#multiple_employees")
    input.value = value ? 1 : 0
    this.current_step += 1
    this.stepDialog()
  },
  stepDialog: function(){
    if(this.current_step == 0){
      this.showDialog("<p>Is this sheet for a single employee or multiple employees?</p><input type='submit' value='single' onclick='uploader.setMultipleEmployees(false)' /> <input type='submit' value='multiple' onclick='uploader.setMultipleEmployees(true)'/>")
    } else if (this.current_step == 1){
      if(multiple_employees){
        this.showDialog("Select the cell with the first " + this.data_finders[this.current_step - 1])
      } else {
        this.showDialog("Select the cell with the employee's name")
      }
    } else if (this.current_step < this.data_finders.length + 1){
      this.showDialog("Select the cell with the first " + this.data_finders[this.current_step - 1])
    } else {
      if(this.validateFinders()){
        if(this.detectFinders()){
          this.showDialog("Ready to submit<br/>\
            <input type='submit' onclick='document.querySelector(\"#fileform\").submit();'/> \
            <input type='submit' value='Start Over' onclick='uploader.startOverOnClick();return false'/>"
          )
        } else {
          this.showDialog("Error processing, please reset")
        }
      }
    }
  },
  tableCellClick: function(event){
    if (this.current_step == 0){
      return
    }
    var radios = document.querySelectorAll('.cell_type:checked') 
    if(event.target.clicked == undefined){
      event.target.style.border = "1px solid " + this.colors[this.current_step - 1]
      event.target.clicked = true
      this.data_finder_cells[this.data_finders[this.current_step - 1]] = new Cell(event.target.parentElement.rowIndex, event.target.cellIndex, event.target.innerHTML)
      this.current_step += 1
      this.stepDialog()
    } else {
      alert("This cell has already been clicked")
    }
  },
  handleFileSelect: function(evt) {
    var local_uploader = this
    var files = evt.target.files; 
    for (var i = 0, f; f = files[i]; i++) {
      var reader = new FileReader()
      var table = document.querySelector("#table")
      var tbody = document.createElement('tbody')
      table.innerHTML = ''
      table.appendChild(tbody)
      table = tbody
      reader.onload = function(event){ 
        var char_index = 0
        var cell_value = ''
        var table_row = document.createElement('tr')
        var table_cell = document.createElement('td')
        table_cell.onclick = local_uploader.tableCellClick.bind(local_uploader);
        var current_char
        while(char_index < this.result.length){
          current_char = this.result[char_index]
          if(this.result[char_index] == ','){
            table_cell.innerHTML = cell_value
            table_row.appendChild(table_cell)
            table_cell = document.createElement('td')
            table_cell.onclick = local_uploader.tableCellClick.bind(local_uploader);
            table_cell.className = "table_cell"
            cell_value = ''
          } else if(current_char == '\n' || current_char == '\r'){
            table.appendChild(table_row)
            table_row = document.createElement('tr')
            cell_value = ''
          } else {
            cell_value += this.result[char_index]
          }
          char_index += 1;
        }
        local_uploader.stepDialog()
      }.bind(reader);
      reader.readAsText(f);
    }
  }
}

var uploader = new CSVUploader()
$(function() {
  document.getElementById('files').addEventListener('change', uploader.handleFileSelect.bind(uploader), false);
})

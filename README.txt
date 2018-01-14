# A SQL script that adds code to the procedure
#creates a table with the name procedure name+"_log" and adds to the procedure the code to loging the input constraints of this procedure in table
#input constraints: proc_name - procedure name , infection - change parameter ('1'- add code,'0'- delete code) 
#example: "execute procedure recompil_2('procedure name','1');"

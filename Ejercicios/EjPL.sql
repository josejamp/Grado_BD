/* 1 */

create or replace function cupo_curso(codigo_curso  in char ) return boolean
is
   n_plazas number(3);
   n_insc number;
  begin
   select cursos.plazas into n_plazas
   from cursos
   where cursos.codigo = codigo_curso;
   select count(*) into n_insc
   from  inscripciones
   where inscripciones.codigo = codigo_curso;
   return n_insc < n_plazas;
end;
/

declare
  cupo boolean;
begin
  --cupo := cupo_curso('C1');
  if(cupo_curso('C1')) then 
  dbms_output.put_line('Hay cupo');
  else 
  dbms_output.put_line('No hay cupo');
  end if;
  --dbms_output.put_line(cupo);
end;
/

create or replace procedure inscribir(codigo_curso in char, id_estudiante in varchar, antiguo in number)
is
   importe number(6,2);
   tipo_curso varchar(10);
   horas number(3);
   nivel_curso varchar(20);
  begin
   if(cupo_curso(codigo_curso)) then
      select cursos.tipo, cursos.horas, cursos.nivel into tipo_curso, horas, nivel_curso
      from cursos
      where cursos.codigo = codigo_curso;   
      select cuotas.importe into importe
      from cuotas
      where cuotas.nivel = nivel_curso and
            cuotas.tipo = tipo_curso;
      if(tipo_curso like 'Particular') then
        importe := importe*horas;
      end if;
      if(antiguo = 1) then
        importe := (importe*95)/100;
      end if;     
      insert into inscripciones values (codigo_curso, id_estudiante, importe, antiguo);     
   else
      dbms_output.put_line('No se pudo realizar la inscripcion');
   end if;
end;
/

begin
inscribir('C1', 'Segundo', 1);
end;
/


create or replace procedure listado(numMatriculas number)
is
 /* codigo cursos.codigo%type;
  nombre cursos.nombre%type;
  nivel cursos.nivel%type;
  inscripciones number;
  importeTotal number;*/

  cursor cursorLista is
  select cursos.codigo, cursos.nombre, cursos.nivel, count(*) as inscripciones, sum(inscripciones.importe) as importeTotal
  from inscripciones, cursos
  where cursos.codigo = inscripciones.codigo
  group by cursos.codigo, cursos.nombre, cursos.nivel
  having count(*) > numMatriculas
  order by cursos.nivel;
  rCursos cursorLista%rowtype;
  
  begin
  open cursorLista;
  loop
    fetch cursorLista into rCursos; --(codigo, nombre, nivel, inscripciones, importeTotal);
    exit when cursorLista%notfound;
    dbms_output.put_line(rCursos.codigo || ', ' || rCursos.nombre || ', '|| rCursos.nivel || ', ' || rCursos.inscripciones || ', ' || rCursos.importeTotal);
  end loop;
  close cursorLista;
end;
/

begin
  listado(1);
end;
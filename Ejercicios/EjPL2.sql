/* 2 */

drop table ComisionCC;
drop table deposito;
drop table logM;

create table ComisionCC (cc char(20), importe number(10,2));
create table deposito(cc char(20));
create table logM(msg varchar(50));

/*
create or replace trigger triggerBorrado
before delete on ComisionCC
for each row
declare
  ccBuscado char(20);
  esta boolean;
  mensaje char(20);
  
  cursor busqueda is
  select deposito.cc
  from deposito;
  
begin
  esta := false;
  open busqueda;
    loop
      fetch busqueda into ccBuscado; 
      exit when (busqueda%notfound or esta);
      if (ccBuscado=:old.cc) then 
      esta := true;
      end if;
    end loop;
    close busqueda;
     if(esta) then
        mensaje := ', Deposito Asociado.';
     else
        mensaje := ', CP.';
     end if;
     insert into logM values (:old.cc || :old.importe || mensaje);
end;
/
*/

create or replace trigger triggerBorrado
before delete on ComisionCC
for each row
declare
  esta number;
  
begin

  select count(*) into esta
  from deposito
  where deposito.cc = :old.cc;
  
  if(esta > 0) then
    insert into logM values(:old.cc || :old.importe || 'Deposito asociado');
  else
    insert into logM values(:old.cc || :old.importe || 'Deposito preferente');
  end if;
  
end;
/

insert into Comisioncc values ('12345678900987654321',13.9);
insert into Comisioncc values('12345123131333344321',13.0);
insert into Comisioncc values ('37423462487654321478',13.9);
insert into deposito values ('37423462487654321478');
delete from ComisionCC;
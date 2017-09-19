drop table Cliente cascade constraints;
drop table Oferta cascade constraints;
drop table Tipo cascade constraints;
drop table Restaurante cascade constraints;
drop table Opinion cascade constraints;
drop table Oferta_Restaurante cascade constraints;
drop table Reservas_Cliente cascade constraints;
drop table Reserva cascade constraints;
drop table Descuento cascade constraints;
drop sequence OpinionSC;
drop sequence importeSC;
drop sequence ofertaSC;

  create sequence opinionSC  minvalue 1 start with 1
    increment by 1 nocache;
  
  create sequence importeSC  minvalue 1 start with 1
    increment by 1 nocache;
    
  create sequence ofertaSC  minvalue 0 start with 0
    increment by 1 nocache;

create table Cliente(
  categoria varchar2(10) default 'Esporadico' 
                         constraint cat_CK check (categoria in('Esporadico', 'Experto', 'Frecuente')),
  telefono number(11), /* 2 digitos internacionales + 9 digitos  */
  CP number(5) not null,
  cpassword varchar2(50) not null,
  correo varchar2(50) primary key
);

create table Oferta(
  id_oferta number primary key,
  tipo varchar2(5) default 'carta' not null  /* posibles tipos de ofertas */
                   constraint tipo_CK check (tipo in('20%', '50%', '18', '20', '30', 'carta'))
);

create table Tipo( /* Tipo de restaurante */
  nombre varchar2(50) primary key
);

create table Restaurante(
  NIF char(9) primary key,
  calle varchar2(50) not null,
  ciudad varchar2(20) not null,
  CP number(5) not null,
  nombre varchar2(50) not null,
  tipo varchar2(50) references Tipo on delete set null
);

create table Opinion(
  id_opinion number primary key,
  calidad number(2,0) check (calidad <= 10 and calidad >= 0), /* las notas deben estar entre 0 y 10 */
  servicio number(2,0) check (servicio <= 10 and servicio >= 0),
  precio number(2,0) check (precio <= 10 and precio >= 0),
  NIF char(9) references Restaurante on delete cascade
);

create table Oferta_Restaurante(
  id_oferta number references Oferta on delete cascade,
  NIF char(9) references Restaurante on delete cascade,
  constraint PK_OR primary key(id_oferta, NIF)
);

create table Reservas_Cliente(
  NIF char(9) references Restaurante on delete cascade,
  n_veces number default 0,
  correo varchar2(50) references Cliente on delete cascade,
  constraint PK_RC primary key(NIF, correo)
);

create table Reserva(
  id_oferta number,
  NIF char(9) not null,
  n_comensales number not null,
  efectuada number(1,0) default 0 not null
                        check(efectuada in(0,1)),
  id_reserva number primary key,
  fecha_hora date not null,
  nota_calidad number(2,0) check (nota_calidad <= 10 and nota_calidad >= 0),
  nota_servicio number(2,0) check (nota_servicio <= 10 and nota_servicio >= 0),
  nota_precio number(2,0) check (nota_precio <= 10 and nota_precio >= 0),
  correo varchar2(50) not null references Cliente on delete cascade,
  constraint FK_R foreign key (id_oferta, NIF) references Oferta_Restaurante(id_oferta, NIF),
  constraint CH_H check((to_char(fecha_hora, 'HH24') between '13' and '15') or /* la hora debe estar entre la una y las tres am*/
                        (to_char(fecha_hora, 'HH24') between '21' and '23'))   /* o las nueve y las once pm*/
);

create table Descuento(
  importe number not null,
  id_descuento number,
  fecha_caducidad Date not null,
  id_reserva references Reserva on delete set null,
  correo references Cliente on delete cascade,
  constraint PK_Desc primary key(id_descuento, correo)
);
/


/* Trigger para asegurarnos de que todos los restaurantes ofrecen carta */
create or replace trigger carta
after insert on Restaurante
for each row

declare

  existeOfertaCarta number; -- para guardar si existe alguna fila en la tabla Oferta cuyo tipo sea 'carta'
  idOfertaAux number; -- para guardar el id de la alguna Oferta que ofrezca carta

begin
  
  select count(*) into existeOfertaCarta /* vemos si alguna Oferta es 'carta' */
  from Oferta
  where Oferta.tipo like 'carta';
  
  if(existeOfertaCarta = 0) then /* si o hay ninguna de ese tipo la creamos y la insertamos en la tabla */
    insert into Oferta values(ofertaSC.NEXTVAL, 'carta');
  end if;
  
   /* buscamos una oferta cuyo tipo sea 'carta' */
    select Oferta.id_oferta into idOfertaAux
    from Oferta
    where Oferta.tipo like 'carta' and
          ROWNUM = 1;
    insert into Oferta_Restaurante values(idOfertaAux, :new.NIF); /* hacemos que el restaurante la ofrezca */
  
end;
/

insert into Tipo(nombre) values ('Mexicana');
insert into Tipo(nombre) values ('Italiana');
insert into Restaurante(NIF, calle, ciudad, CP, nombre, tipo) values ('000000000', 'calle uno', 'Madrid', 28034, 'Patata Frita', 'Mexicana');
insert into Restaurante(NIF, calle, ciudad, CP, nombre, tipo) values ('000000001', 'calle dos', 'Madrid', 28024, 'Frijolito', 'Mexicana');
insert into Restaurante(NIF, calle, ciudad, CP, nombre, tipo) values ('000000002', 'calle tres', 'Madrid', 28029, 'Pizza', 'Italiana');
insert into Restaurante(NIF, calle, ciudad, CP, nombre, tipo) values ('000000003', 'piloswine', 'Madrid', 28067, 'kilogramo', 'Italiana');
insert into Opinion(id_opinion, calidad, servicio, precio, NIF) values (99, 5, 5, 5, '000000000');
insert into Opinion(id_opinion, calidad, servicio, precio, NIF) values (100, 10, 5, 0, '000000000');
insert into Opinion(id_opinion, calidad, servicio, precio, NIF) values (101, 8, 5, 8, '000000000');
insert into Opinion(id_opinion, calidad, servicio, precio, NIF) values (102, 5, 5, 5, '000000001');
insert into Opinion(id_opinion, calidad, servicio, precio, NIF) values (103, 10, 9, 10, '000000001');
insert into Opinion(id_opinion, calidad, servicio, precio, NIF) values (104, 4, 7, 4, '000000002');
insert into Cliente(categoria, telefono, CP, cpassword, correo) values ('Esporadico', 911234567, 28666, 'orcoDeMordor', 'orco@mordor.mord');
insert into Cliente(categoria, telefono, CP, cpassword, correo) values ('Esporadico', 910000000, 28099, 'contrasegna', 'fanboy@gmail.com');
insert into Cliente(categoria, telefono, CP, cpassword, correo) values ('Esporadico', 630246923, 28622, 'vivaKirby', 'fangirl@hotmail.com');
insert into Oferta(id_oferta, tipo) values (ofertaSC.NEXTVAL, '20%');
insert into Oferta_Restaurante(id_oferta, nif) values (1, '000000000'); 
insert into Reservas_Cliente(nif, n_veces, correo) values ('000000000', 8, 'orco@mordor.mord');
insert into Reserva(id_oferta, NIF, n_comensales, efectuada, id_reserva, fecha_hora, nota_calidad, nota_servicio, nota_precio, correo) values (00000, '000000000', 3, 1, 00000, to_date('2013-02-10 13:00', 'YYYY-DD-MM HH24:MI'), 8, 8, 8, 'orco@mordor.mord');
insert into Reserva(id_oferta, NIF, n_comensales, efectuada, id_reserva, fecha_hora, nota_calidad, nota_servicio, nota_precio, correo) values (00000, '000000001', 3, 1, 00001, to_date('2013-02-10 21:00', 'YYYY-DD-MM HH24:MI'), 8, 8, 8, 'fanboy@gmail.com');
insert into Reserva(id_oferta, NIF, n_comensales, efectuada, id_reserva, fecha_hora, nota_calidad, nota_servicio, nota_precio, correo) values (00000, '000000003', 3, 0, 00002, to_date('2013-02-10 14:00', 'YYYY-DD-MM HH24:MI'), null, null, null, 'fanboy@gmail.com');
insert into Reserva(id_oferta, NIF, n_comensales, efectuada, id_reserva, fecha_hora, nota_calidad, nota_servicio, nota_precio, correo) values (00000, '000000002', 3, 0, 00003, to_date('2014-02-10 13:00', 'YYYY-DD-MM HH24:MI'), null, null, null, 'fangirl@hotmail.com');
insert into Reserva(id_oferta, NIF, n_comensales, efectuada, id_reserva, fecha_hora, nota_calidad, nota_servicio, nota_precio, correo) values (00000, '000000000', 3, 0, 00004, to_date('2013-03-10 22:00', 'YYYY-DD-MM HH24:MI'), null, null, null, 'fangirl@hotmail.com');
insert into Reserva(id_oferta, NIF, n_comensales, efectuada, id_reserva, fecha_hora, nota_calidad, nota_servicio, nota_precio, correo) values (00000, '000000001', 3, 1, 00005, to_date('2013-02-11 21:00', 'YYYY-DD-MM HH24:MI'), 9, 9, 9, 'fanboy@gmail.com');
insert into Reserva(id_oferta, NIF, n_comensales, efectuada, id_reserva, fecha_hora, nota_calidad, nota_servicio, nota_precio, correo) values (00000, '000000002', 3, 1, 00006, to_date('2013-02-12 21:00', 'YYYY-DD-MM HH24:MI'), null, null, null, 'fanboy@gmail.com');
insert into Reserva(id_oferta, NIF, n_comensales, efectuada, id_reserva, fecha_hora, nota_calidad, nota_servicio, nota_precio, correo) values (00000, '000000001', 3, 1, 00007, to_date('2013-03-10 13:00', 'YYYY-DD-MM HH24:MI'), null, 8, null, 'orco@mordor.mord');
insert into Descuento(importe, id_descuento, fecha_caducidad, id_reserva, correo) values (1, 00000, to_date('2013-16-10', 'YYYY-DD-MM'), null, 'fanboy@gmail.com');
insert into Descuento(importe, id_descuento, fecha_caducidad, id_reserva, correo) values (3, 00001, to_date('2014-16-10', 'YYYY-DD-MM'), 00003, 'fangirl@hotmail.com');
insert into Descuento(importe, id_descuento, fecha_caducidad, id_reserva, correo) values (7, 00002, to_date('2014-16-10', 'YYYY-DD-MM'), 00001, 'fanboy@gmail.com');
insert into Descuento(importe, id_descuento, fecha_caducidad, id_reserva, correo) values (13, 00003, to_date('2014-16-10', 'YYYY-DD-MM'), 00002, 'fanboy@gmail.com');
insert into Descuento(importe, id_descuento, fecha_caducidad, id_reserva, correo) values (33, 00004, to_date('2013-16-10', 'YYYY-DD-MM'), 00000, 'orco@mordor.mord');
insert into Descuento(importe, id_descuento, fecha_caducidad, id_reserva, correo) values (101, 00005, to_date('2013-25-10', 'YYYY-DD-MM'), 00004, 'fangirl@hotmail.com');


/* apartado 5 */
create or replace trigger tDescuentos
after update on Cliente
for each row

begin
  if (:new.categoria like 'Frecuente') then /* si el cliente pasa a ser frecuente se le asigna un descuento de 10 euros */
    insert into Descuento values ( 10, importeSC.NEXTVAL, sysdate + 90, null, :old.correo );
  elsif (:new.categoria like 'Experto') then /* si el cliente pasa a ser experto se le otorga un descuento de 25 euros */
    insert into Descuento values ( 25, importeSC.NEXTVAL, sysdate + 90, null, :old.correo );
  end if;
end;
/

/* apartado 3 */
create or replace procedure mantenimiento
as
  
   v_nveces number; -- Para guardar el numero de veces que un cliente a comido en un restaurante
   numFilas number; -- Para saber si el cliente ya se encuentra en la tabla
   totalDesc number; -- Para sumar los descuentos no utilizados
   utilizado number; -- Para guardar si un descuento se ha utilizado o no
  
  cursor cursorReservas is /* cursor que recorre reservas para el mantenimiento */
  select Reserva.id_reserva as v_idr, Reserva.NIF as v_rnif, Reserva.correo as v_corr, Reserva.efectuada as v_ref, Reserva.fecha_hora as v_rfh, Reserva.nota_calidad as v_cal , Reserva.nota_servicio as v_serv, Reserva.nota_precio as v_pr
  from Reserva;
  rReserv cursorReservas%rowtype;
  
  cursor cursorDescuento is /* cursor que recorre los descuentos para borrar los caducados, etc */
  select Descuento.importe, Descuento.id_descuento, Descuento.fecha_caducidad, Descuento.id_reserva, Descuento.correo
  from Descuento;
  rDesc cursorDescuento%rowtype;
  
  begin
  totalDesc := 0;
  open cursorDescuento; /* hacemos las labores de mantenimiento en los descuentos antes que en las reservas */
  loop
    fetch cursorDescuento into rDesc;
    exit when cursorDescuento%notfound;
    select count(*) into utilizado /* miramos si se ha utilizado un descuento en una reserva comprobando que esta se ha efectuado */
    from Reserva
    where Reserva.id_reserva = rDesc.id_reserva and
          Reserva.efectuada = 1;
    if (utilizado = 0) then /* si no se ha utilizado el descuento: */
      totalDesc := totalDesc + rDesc.importe; /* lo sumamos al total */
      if (( sysdate - rDesc.fecha_caducidad) > 0) then /* si el descuento ha caducado: mostramos la información relativa a este */
         dbms_output.put_line('Id: ' || rDesc.id_descuento || ' Cliente: ' || rDesc.correo || ' Importe: ' || rDesc.importe);
         delete from Descuento where Descuento.id_descuento = rDesc.id_descuento; /* y lo borramos */
      end if;
    end if;
  end loop;
  close cursorDescuento; /* cerramos el cursor */
  dbms_output.put_line('Total de los importes de los descuentos no utilizados: ' || totalDesc ); /* mostramos el total del importe de los descuentos no utilizados */
  
  open cursorReservas; /* abrimos las reservas */
  loop
    fetch cursorReservas into rReserv;
    exit when cursorReservas%notfound;
    if ((sysdate - rReserv.v_rfh) > 30) then /* si la reserva es de hace mas de treinta dias:  */
      if (rReserv.v_ref = 1) then /* si la reserva se efectuo */
        if((rReserv.v_cal is not null) or (rReserv.v_serv is not null) or (rReserv.v_pr is not null)) then /* si el cliente dejo su opinion, esta se guarda*/
          insert into Opinion values (opinionSC.NEXTVAL , rReserv.v_cal, rReserv.v_serv, rReserv.v_pr, rReserv.v_rnif);
        end if;
        select count(*) into numFilas /* miramos si el ya existe la relacion "ha comido en " entre cliente y restaurante para crearla o no */
        from Reservas_cliente
        where rReserv.v_rnif = Reservas_Cliente.NIF and
              rReserv.v_corr = Reservas_Cliente.correo;
        if (numFilas > 0 ) /* si ya existe actualizamos la tabla */
        then
          update Reservas_Cliente  -- actualizar la tabla Reservas_Cliente 
          set Reservas_Cliente.n_veces = Reservas_Cliente.n_veces + 1
          where rReserv.v_rnif = Reservas_Cliente.NIF and
                rReserv.v_corr = Reservas_Cliente.correo;
        else /* si no existe creamos la entrada */
          insert into Reservas_Cliente values(rReserv.v_rnif, 1, rReserv.v_corr);
        end if;
        select Reservas_Cliente.n_veces into v_nveces /* miramos las veces que un cliente ha comido en un restaurante */
        from Reservas_Cliente
        where rReserv.v_rnif = Reservas_Cliente.NIF and
              rReserv.v_corr = Reservas_Cliente.correo;
        if v_nveces > 15 then /* si ha comido mas de quince veces le actualizamos a experto */
            update Cliente
            set Cliente.categoria = 'Experto'
            where Cliente.correo = rReserv.v_corr;
        elsif ((v_nveces > 8) and (v_nveces <= 15)) then /* si ha comido mas de ocho pero menos de quince le actualizamos a frecuente*/
            update Cliente
            set Cliente.categoria = 'Frecuente'
            where Cliente.correo = rReserv.v_corr;
        end if;       
      end if;
      delete from Reserva where Reserva.id_reserva = rReserv.v_idr; /* borrar la reserva con mas de treinta dias */
    end if;
  end loop;
  close cursorReservas;
end;
/

begin
  mantenimiento;
end;
/


/* apartado 4 */
create or replace procedure nota_media
as

  cursor cursorNotas is /* creamos el cursor de notas y calculamos las distintas medias */
  select Opinion.NIF as rest_nif, avg(Opinion.calidad) as media_calidad, avg(Opinion.servicio) as media_servicio, avg(Opinion.precio) as media_precio, avg((Opinion.precio+Opinion.servicio+Opinion.calidad)/3) as nota_media_total
  from Opinion, Restaurante
  where Opinion.NIF = Restaurante.NIF
  group by Opinion.NIF, Restaurante.tipo
  order by Restaurante.tipo asc, nota_media_total desc;
  rNotas cursorNotas%rowtype;

  begin
  open cursorNotas;
  loop
    fetch cursorNotas into rNotas;
    exit when cursorNotas%notfound; /* mostramos las notas medias */
    dbms_output.put_line('NIF: ' || rNotas.rest_nif || ' nota media de calidad: ' || rNotas.media_calidad || ', ' || 'nota media de servicio: ' || rNotas.media_servicio || ', ' || 'nota media de precio: ' || rNotas.media_precio || ', ' || 'nota media total: ' || rNotas.nota_media_total || '.');
  end loop;
  close cursorNotas;
end;
/

begin
  nota_media;
end;
/


/*begin
 update Cliente
 set cliente.categoria = 'Frecuente'
 where cliente.correo = 'orco@mordor.mord';
 update Cliente
 set cliente.categoria = 'Experto'
 where cliente.correo = 'fangirl@hotmail.com';
end;*/


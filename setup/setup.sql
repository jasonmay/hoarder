begin;

drop table if exists message_types;
create table message_types (
    id serial primary key,
    value text
);

drop table if exists messages;
create table messages (
    id serial primary key,
    message text,
    message_type integer
);

commit;

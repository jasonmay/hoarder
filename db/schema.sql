drop table if exists messages;
create table messages (
    id serial primary key,
    nick text,
    message text,
    message_type text,
    network text,
    profile text,
    params json
);

drop table if exists messages;
create table messages (
    id serial primary key,
    nick text,
    message text,
    message_type text,
    channel text,
    network text,
    profile text,
    created timestamp,
    params json
);

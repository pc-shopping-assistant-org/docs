-- Reference DDL for Alembic 0001_stateful + 0002_call_attempts. Apply via Alembic,
-- not by running this documentation file. Native saver tables are separate.
BEGIN;

CREATE TABLE alembic_version (
    version_num VARCHAR(32) NOT NULL, 
    CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num)
);

-- Running upgrade  -> 0001_stateful

CREATE TABLE conversations (
    id UUID NOT NULL, 
    account_id UUID NOT NULL, 
    title VARCHAR(200), 
    revision BIGINT DEFAULT '0' NOT NULL, 
    accepted_checkpoint_id TEXT, 
    active_run_id UUID, 
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
    CONSTRAINT pk_conversations PRIMARY KEY (id), 
    CONSTRAINT ck_conversations_accepted_head CHECK ((revision = 0) = (accepted_checkpoint_id IS NULL)), 
    CONSTRAINT ck_conversations_revision CHECK (revision >= 0), 
    CONSTRAINT ck_conversations_checkpoint_nonblank CHECK (accepted_checkpoint_id IS NULL OR btrim(accepted_checkpoint_id) <> '')
);

CREATE INDEX ix_conversations_owner_list ON conversations (account_id, updated_at DESC, id DESC);

CREATE TABLE agent_runs (
    id UUID NOT NULL, 
    conversation_id UUID NOT NULL, 
    request_id UUID NOT NULL, 
    request_hash VARCHAR(64) NOT NULL, 
    request_payload JSONB NOT NULL, 
    kind VARCHAR(10) NOT NULL, 
    status VARCHAR(30) NOT NULL, 
    base_revision BIGINT NOT NULL, 
    base_checkpoint_ref JSONB, 
    last_checkpoint_ref JSONB, 
    final_checkpoint_ref JSONB, 
    executor_stop_evidence JSONB, 
    versions JSONB, 
    error JSONB, 
    replay_snapshot JSONB, 
    authorized_recovery_source_refs JSONB DEFAULT '[]'::jsonb NOT NULL, 
    execution_id UUID, 
    worker_instance_id UUID, 
    lease_generation BIGINT DEFAULT '0' NOT NULL, 
    lease_expires_at TIMESTAMP WITH TIME ZONE, 
    heartbeat_at TIMESTAMP WITH TIME ZONE, 
    cancel_requested BOOLEAN DEFAULT false NOT NULL, 
    attempt_count INTEGER NOT NULL, 
    max_attempts INTEGER NOT NULL, 
    retry_policy_version TEXT NOT NULL, 
    retry_deadline TIMESTAMP WITH TIME ZONE NOT NULL, 
    trace_id TEXT, 
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
    started_at TIMESTAMP WITH TIME ZONE, 
    finished_at TIMESTAMP WITH TIME ZONE, 
    CONSTRAINT pk_agent_runs PRIMARY KEY (id), 
    CONSTRAINT uq_agent_runs_scoped_id UNIQUE (conversation_id, id), 
    CONSTRAINT ck_agent_runs_request_hash CHECK (request_hash ~ '^[0-9a-f]{64}$'), 
    CONSTRAINT ck_agent_runs_kind CHECK (kind IN ('CHAT','DEBUG','REPLAY')), 
    CONSTRAINT ck_agent_runs_status CHECK (status IN ('PENDING','RUNNING','RECOVERING','WAITING_INPUT','COMPLETED','FAILED_RETRYABLE','FAILED_TERMINAL','CANCELLED')), 
    CONSTRAINT ck_agent_runs_request_payload CHECK (jsonb_typeof(request_payload) = 'object'), 
    CONSTRAINT ck_agent_runs_generations CHECK (base_revision >= 0 AND lease_generation >= 0), 
    CONSTRAINT uq_agent_runs_request UNIQUE (conversation_id, request_id), 
    CONSTRAINT fk_agent_runs_conversation_id FOREIGN KEY(conversation_id) REFERENCES conversations (id) ON DELETE CASCADE, 
    CONSTRAINT ck_agent_runs_recovery_refs CHECK (jsonb_typeof(authorized_recovery_source_refs) = 'array'), 
    CONSTRAINT ck_agent_runs_attempts CHECK (attempt_count >= 0 AND max_attempts > 0)
);

CREATE INDEX ix_agent_runs_lease ON agent_runs (status, lease_expires_at);

CREATE INDEX ix_agent_runs_conversation ON agent_runs (conversation_id, created_at, id);

CREATE TABLE conversation_messages (
    id UUID NOT NULL, 
    conversation_id UUID NOT NULL, 
    run_id UUID NOT NULL, 
    sequence BIGINT NOT NULL, 
    role VARCHAR(10) NOT NULL, 
    content TEXT NOT NULL, 
    payload JSONB, 
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
    CONSTRAINT pk_conversation_messages PRIMARY KEY (id), 
    CONSTRAINT fk_messages_scoped_run FOREIGN KEY(conversation_id, run_id) REFERENCES agent_runs (conversation_id, id) ON DELETE CASCADE, 
    CONSTRAINT uq_messages_sequence UNIQUE (conversation_id, sequence), 
    CONSTRAINT ck_conversation_messages_role CHECK (role IN ('user','assistant')), 
    CONSTRAINT fk_conversation_messages_conversation_id FOREIGN KEY(conversation_id) REFERENCES conversations (id) ON DELETE CASCADE, 
    CONSTRAINT ck_conversation_messages_content CHECK (btrim(content) <> ''), 
    CONSTRAINT uq_messages_run_role UNIQUE (run_id, role), 
    CONSTRAINT ck_conversation_messages_sequence CHECK (sequence > 0)
);

ALTER TABLE conversations ADD CONSTRAINT fk_conversations_active_run FOREIGN KEY(id, active_run_id) REFERENCES agent_runs (conversation_id, id) DEFERRABLE INITIALLY DEFERRED;

INSERT INTO alembic_version (version_num) VALUES ('0001_stateful') RETURNING alembic_version.version_num;

-- Running upgrade 0001_stateful -> 0002_call_attempts
CREATE TABLE agent_call_budgets (
    run_id UUID NOT NULL PRIMARY KEY REFERENCES agent_runs(id) ON DELETE CASCADE,
    model_limit INTEGER NOT NULL,
    tool_io_limit INTEGER NOT NULL,
    deadline TIMESTAMP WITH TIME ZONE NOT NULL,
    CONSTRAINT ck_agent_call_budgets_limits CHECK (model_limit >= 0 AND tool_io_limit >= 0)
);
CREATE TABLE agent_call_attempts (
    id UUID NOT NULL PRIMARY KEY,
    run_id UUID NOT NULL REFERENCES agent_call_budgets(run_id) ON DELETE CASCADE,
    execution_id UUID NOT NULL,
    worker_instance_id UUID NOT NULL,
    generation BIGINT NOT NULL,
    kind VARCHAR(10) NOT NULL,
    operation_key VARCHAR(200) NOT NULL,
    request_hash VARCHAR(64) NOT NULL,
    attempt_number INTEGER NOT NULL,
    status VARCHAR(10) DEFAULT 'RESERVED' NOT NULL,
    reserved_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    finished_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT uq_call_attempt_operation UNIQUE (run_id, operation_key, attempt_number),
    CONSTRAINT ck_agent_call_attempts_positive_identity CHECK (generation > 0 AND attempt_number > 0),
    CONSTRAINT ck_agent_call_attempts_kind CHECK (kind IN ('MODEL','TOOL_IO')),
    CONSTRAINT ck_agent_call_attempts_status CHECK (status IN ('RESERVED','SUCCEEDED','FAILED','UNKNOWN')),
    CONSTRAINT ck_agent_call_attempts_operation_key CHECK (btrim(operation_key) <> ''),
    CONSTRAINT ck_agent_call_attempts_request_hash CHECK (request_hash ~ '^[0-9a-f]{64}$'),
    CONSTRAINT ck_agent_call_attempts_finished CHECK ((status = 'RESERVED') = (finished_at IS NULL))
);
CREATE INDEX ix_call_attempt_run_kind ON agent_call_attempts (run_id, kind);
UPDATE alembic_version SET version_num='0002_call_attempts' WHERE version_num='0001_stateful';
COMMIT;

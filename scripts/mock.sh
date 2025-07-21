#!/bin/bash

# Function to generate random hex string
generate_hex() {
    length=$1
    head -c $((length/2)) /dev/urandom | xxd -p
}

# Function to generate random address
generate_address() {
    echo "0x$(generate_hex 40)"
}

# Function to generate random hash
generate_hash() {
    echo "0x$(generate_hex 64)"
}

# Function to generate ISO timestamp
generate_timestamp() {
    now=$(date +%s)
    past=$((now - RANDOM % (30*24*60*60)))
    if [[ "$OSTYPE" == "darwin"* ]]; then
        date -r $past -u +"%Y-%m-%d %H:%M:%S"
    else
        date -d "@$past" -u +"%Y-%m-%d %H:%M:%S"
    fi
}

# Create temporary directory
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "Using temporary directory: $TEMP_DIR"

# Generate blocks data
echo "Generating blocks data..."
{
    # First line is header
    echo "number|hash|transaction_count|internal_transaction_count|validator|difficulty|total_difficulty|size|nonce|gas_used|gas_limit|extra_data|parent_hash|sha3_uncle|timestamp|l1_batch_number|l1_batch_timestamp|inserted_at|updated_at|trace_checked|check_trace_count"
    
    # Generate data lines
    for i in {1..1000}; do
        timestamp=$(( $(date +%s) - RANDOM % (30*24*60*60) ))
        now=$(date -u +"%Y-%m-%d %H:%M:%S")
        difficulty=$((RANDOM % 1000000))
        total_difficulty=$((difficulty * i))
        
        # Ensure all fields are present and in correct order
        printf "%d|%s|%d|%d|%s|%d|%d|%d|%s|%d|%d|%s|%s|%s|%d|%d|%d|%s|%s|%s|%d\n" \
            "$i" \
            "$(generate_hash)" \
            "$((RANDOM % 100))" \
            "$((RANDOM % 50))" \
            "$(generate_address)" \
            "$difficulty" \
            "$total_difficulty" \
            "$((RANDOM % 1000000))" \
            "$(generate_hex 16)" \
            "$((RANDOM % 1000000))" \
            "$((RANDOM % 2000000))" \
            "0x$(generate_hex 32)" \
            "$(generate_hash)" \
            "$(generate_hash)" \
            "$timestamp" \
            "$((RANDOM % 100))" \
            "$timestamp" \
            "$now" \
            "$now" \
            "true" \
            "0"
    done
} > "$TEMP_DIR/blocks.csv"

# Import blocks
echo "Importing blocks..."
psql $DATABASE_URL -c "\COPY blocks FROM '$TEMP_DIR/blocks.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true)"

# Generate transactions data
echo "Generating transactions data..."
{
    echo "id|hash|block_hash|block_number|from_address|to_address|value|fee|l1fee|gas_used|gas_price|gas_limit|method_id|input|nonce|status|transaction_index|transaction_type|max_priority|max_fee|revert_reason|timestamp|inserted_at|updated_at"
    for i in {1..5000}; do
        block_number=$((RANDOM % 1000 + 1))
        block_info=$(psql $DATABASE_URL -At -c "SELECT hash, timestamp FROM blocks WHERE number = $block_number")
        block_hash=$(echo $block_info | cut -d'|' -f1)
        timestamp=$(echo $block_info | cut -d'|' -f2)
        now=$(date -u +"%Y-%m-%d %H:%M:%S")
        
        echo "$i|$(generate_hash)|$block_hash|$block_number|$(generate_address)|$(generate_address)|$((RANDOM % 1000000))|$((RANDOM % 10))|$((RANDOM % 10))|$((RANDOM % 1000000))|$((RANDOM % 100000000))|$((RANDOM % 2000000))|0x$(generate_hex 8)|0x$(generate_hex 128)|$((RANDOM % 10000))|$((RANDOM % 2))|$((RANDOM % 100))|l2|$((RANDOM % 100))|$((RANDOM % 1000))|null|$timestamp|$now|$now"
    done
} > "$TEMP_DIR/transactions.csv"

# Import transactions
echo "Importing transactions..."
psql $DATABASE_URL -c "\COPY transactions FROM '$TEMP_DIR/transactions.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true)"

# Generate and import tokens
echo "Generating tokens data..."
{
    echo "id|name|symbol|address|decimals|total_supply|token_type"
    for i in {1..50}; do
        token_type=$([ $((RANDOM % 3)) -eq 0 ] && echo "erc20" || ([ $((RANDOM % 2)) -eq 0 ] && echo "erc721" || echo "erc1155"))
        total_supply=$((10**9 + RANDOM % 10**9))
        echo "$i|Token_$i|TKN$i|$(generate_address)|18|$total_supply|$token_type"
    done
} > "$TEMP_DIR/tokens.csv"

echo "Importing tokens..."
psql $DATABASE_URL -c "\COPY tokens FROM '$TEMP_DIR/tokens.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true)"

# Generate and import token transfers
echo "Generating token transfers..."
{
    echo "id|transaction_hash|log_index|method_id|token_address|block_number|block_hash|from_address|to_address|value|amount|token_id|amounts|token_ids|token_type|timestamp|inserted_at|updated_at"
    psql $DATABASE_URL -c "COPY (
        WITH transfer_base AS (
            SELECT 
                t.id,
                t.hash,
                t.block_number,
                t.block_hash,
                tok.address as token_address,
                tok.token_type,
                t.from_address,
                t.to_address,
                t.timestamp,
                ROW_NUMBER() OVER (PARTITION BY t.hash ORDER BY tok.address) as log_index
            FROM transactions t 
            CROSS JOIN tokens tok 
            WHERE random() < 0.1
            LIMIT 1000
        )
        SELECT 
            id,
            hash,
            log_index - 1,
            '0x' || encode(gen_random_bytes(4), 'hex'),
            token_address,
            block_number,
            block_hash,
            from_address,
            to_address,
            (random() * 1000000)::numeric(80,0),
            (random() * 1000000)::numeric(80,0),
            (random() * 1000)::numeric(80,0),
            ARRAY[(random() * 1000)::numeric(80,0), (random() * 1000)::numeric(80,0)],
            ARRAY[(random() * 1000)::numeric(80,0), (random() * 1000)::numeric(80,0)],
            token_type,
            timestamp,
            now(),
            now()
        FROM transfer_base
    ) TO STDOUT CSV HEADER DELIMITER '|'" > "$TEMP_DIR/token_transfers.csv"
}

echo "Importing token transfers..."
psql $DATABASE_URL -c "\COPY token_transfers FROM '$TEMP_DIR/token_transfers.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true)"

# Generate and import address balances
echo "Generating address balances..."
psql $DATABASE_URL -c "
    INSERT INTO address_balances (address, balance, updated_block_number, inserted_at, updated_at)
    WITH unique_addresses AS (
        SELECT DISTINCT address FROM (
            SELECT from_address as address FROM transactions
            UNION
            SELECT to_address as address FROM transactions
            WHERE to_address IS NOT NULL
        ) a
    )
    SELECT 
        address, 
        (random() * 1000000)::numeric(100,0),
        (SELECT MAX(number) FROM blocks),
        now(),
        now()
    FROM unique_addresses
    ON CONFLICT (address) DO UPDATE
    SET balance = EXCLUDED.balance,
        updated_block_number = EXCLUDED.updated_block_number,
        updated_at = EXCLUDED.updated_at;"

# Generate and import token balances
echo "Generating token balances..."
psql $DATABASE_URL -c "
    INSERT INTO token_balances (address, token_address, token_id, token_type, balance, updated_block_number, inserted_at, updated_at)
    WITH sample_data AS (
        SELECT DISTINCT 
            t.to_address as address,
            tok.address as token_address,
            CASE 
                WHEN tok.token_type IN ('erc721', 'erc1155') THEN (random() * 1000)::numeric(80,0)
                ELSE NULL
            END as token_id,
            tok.token_type,
            (random() * 1000000)::numeric(80,0) as balance,
            (SELECT MAX(number) FROM blocks) as block_number
        FROM transactions t
        CROSS JOIN tokens tok
        WHERE random() < 0.1
        AND t.to_address IS NOT NULL
    )
    SELECT 
        address,
        token_address,
        token_id,
        token_type,
        balance,
        block_number,
        now(),
        now()
    FROM sample_data
    ON CONFLICT (address, token_address, token_id, token_type) 
    DO UPDATE 
    SET balance = EXCLUDED.balance,
        updated_block_number = EXCLUDED.block_number,
        updated_at = EXCLUDED.updated_at;"

# Create functions and views if they don't exist
echo "Creating functions and views..."
psql $DATABASE_URL -f prisma/schema.sql

# Update statistics
echo "Updating statistics..."
psql $DATABASE_URL -c "
    SELECT update_daily_transaction_count();
    SELECT update_daily_token_transfer_counts();
    SELECT update_daily_unique_address_count();
    SELECT update_daily_gas_used();
    SELECT update_daily_tx_fee();
    SELECT update_daily_block_count();
    SELECT update_daily_block_size();
    SELECT update_daily_block_gas_info();
    SELECT update_daily_txn_gas_info();"

echo "Mock data generation completed!"

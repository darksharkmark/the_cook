import csv

input_file = 'card_data.csv'
output_file = 'card_data_sanitized.csv'

seen_ids = set()
sanitized_rows = []

with open(input_file, newline='', encoding='utf-8') as csvfile:
    reader = csv.reader(csvfile, delimiter='|')
    for row in reader:
        if not row:
            continue
        card_id = row[0]
        if card_id not in seen_ids:
            seen_ids.add(card_id)
            sanitized_rows.append(row)

# Write sanitized CSV
with open(output_file, 'w', newline='', encoding='utf-8') as csvfile:
    writer = csv.writer(csvfile, delimiter='|')
    writer.writerows(sanitized_rows)

print(f"Sanitized CSV saved to {output_file}")

#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/Project3"
flutter pub get --enforce-lockfile > ../evidence/pub_get.txt 2>&1
flutter test test/services/checkout_help_service_test.dart test/services/checkout_help_precision_test.dart test/services/checkout_help_repository_test.dart test/m4_review/checkout_help_adversarial_test.dart --no-pub --concurrency=1 --timeout 30s --reporter expanded --file-reporter expanded:../evidence/m4_unit.txt > ../evidence/unit_console.txt 2>&1
flutter test test/screens/checkout_help_screen_test.dart test/m4_review/checkout_help_basket_acceptance_test.dart --no-pub --concurrency=1 --timeout 30s --reporter expanded --file-reporter expanded:../evidence/m4_widget.txt > ../evidence/widget_console.txt 2>&1
flutter test test/project1a/supreme_uc16-20_test.dart test/project1a/satwi_uc11-15_test.dart test/active/project1a_coverage_gaps_test.dart --no-pub --concurrency=1 --reporter expanded --file-reporter expanded:../evidence/m0_team.txt > ../evidence/team_console.txt 2>&1
flutter test test/project1a/aditya_uc6-10_test.dart --plain-name 'UC8 - Add product to basket' --no-pub --concurrency=1 --reporter expanded --file-reporter expanded:../evidence/m0_allowance.txt > ../evidence/allowance_console.txt 2>&1
flutter test test/screens/qr_checkout_screen_test.dart test/screens/basket_screen_test.dart --no-pub --concurrency=1 --reporter expanded --file-reporter expanded:../evidence/m0_inherited.txt > ../evidence/inherited_console.txt 2>&1
cd ../Project2_Work/M0
python3 -m unittest -v test_evaluate_checkout_trials.py > ../../evidence/m0_scoring.txt 2>&1
python3 evaluate_checkout_trials.py trial_data/passing_example.json > ../../evidence/scoring_passing_example.txt
python3 evaluate_checkout_trials.py trial_data/failing_example.json > ../../evidence/scoring_failing_example.txt

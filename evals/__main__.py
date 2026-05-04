"""CLI entry point: python -m evals"""

import argparse
import sys

from evals import CATEGORIES


def main() -> None:
    parser = argparse.ArgumentParser(description="Run Dash evals")
    subparsers = parser.add_subparsers(dest="command")

    # --- Smoke tests ---
    smoke_parser = subparsers.add_parser("smoke", help="Run lightweight smoke tests")
    from evals.smoke import TESTS
    all_groups = sorted(set(t.group for t in TESTS))
    smoke_parser.add_argument(
        "--group",
        type=str,
        choices=all_groups,
        help=f"Run only one test group ({', '.join(all_groups)})",
    )
    smoke_parser.add_argument("--verbose", "-v", action="store_true", help="Show full responses")

    args = parser.parse_args()

    if args.command == "smoke":
        from evals.smoke import run_smoke_tests
        results = run_smoke_tests(group=args.group, verbose=args.verbose)
        sys.exit(1 if any(r.status != "PASS" for r in results) else 0)
    else:
        parser.print_help()
        sys.exit(0)


main()

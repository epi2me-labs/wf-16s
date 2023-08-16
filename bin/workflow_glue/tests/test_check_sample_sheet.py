"""Test check_sample_sheet.py."""

import os

import pytest
from workflow_glue import check_sample_sheet


# define a list of error messages (either the complete message or the first couple words
# in case the error message is customized by `check_sample_sheet.py`) and required
# sample types to be tested.
ERROR_MESSAGES = [
    ("sample_sheet_1.csv", "Sample sheet requires at least 1 of ", "positive_control"),
    ("sample_sheet_2.csv", "Not an allowed sample type: ", "invalid_sample_type"),
    ("missing.csv", "Could not open sample sheet", ""),
    ("utf8_bom.csv", "", ""),  # check this does not fail
]


@pytest.fixture
def test_data(request):
    """Define data location fixture."""
    return os.path.join(
        request.config.getoption("--test_data"),
        "workflow_glue",
        "check_sample_sheet")


@pytest.mark.parametrize("sample_sheet_name,error_msg,required_types", ERROR_MESSAGES)
def test_check_sample_sheet(
        capsys, test_data, sample_sheet_name, error_msg, required_types):
    """Test the sample sheets."""
    expected_error_message = error_msg
    sample_sheet_path = f"{test_data}/{sample_sheet_name}"
    args = check_sample_sheet.argparser().parse_args(
        [sample_sheet_path, '--required_sample_types', required_types]
    )
    try:
        check_sample_sheet.main(args)
    except SystemExit:
        pass
    out, _ = capsys.readouterr()
    if expected_error_message == "":
        assert len(out.strip()) == 0
    else:
        assert out.startswith(expected_error_message)

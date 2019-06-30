# frozen_string_literal: true

def is_expected_to_raise(error_type)
  expect { subject }.to raise_error(error_type)
end

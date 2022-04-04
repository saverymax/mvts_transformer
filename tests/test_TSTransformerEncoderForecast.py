"""
Module for testing the forecasting transformer layer.

Some ideas from: https://github.com/suriyadeepan/torchtest/blob/master/torchtest/torchtest.py
"""

from models.ts_transformer import TSTransformerEncoderForecast, build_output_layer
from models.loss import get_loss_module

@pytest.fixture
def generate_forecast_data(batch_size, seq_len, h_dim):
    """
    Generate forecast data
    """
    X = torch.ones(batch_size, seq_len, h_dim)

    return X

    
def assert_uses_gpu():
    """
    Make sure GPU is available and accessible
    """
    assert torch.cuda.is_available()


def test_model():
    """
    Test model shapes and output
    """
    model = TSTransformerEncoderForecast()
    output = model(input)
    assertEqual(output.shape, (batch_size, seq_length, num_classes))


def test_output_layer()
    """
    Test the size of the output layer
    """
    d_model = 128
    num_classes = 1
    X = generate_forecast_data
    output_layer = build_output_layer(d_model, num_classes)


def test_never_nan():
    assert not torch.isnan(tensor).byte().any()

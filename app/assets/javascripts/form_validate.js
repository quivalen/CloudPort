var targetAddressField = document.getElementById('target_address');
var validTargetAddressRegex = /^[a-z0-9][a-z0-9\.\-]*$/;
var targetAddressValidBackgroundColor = targetAddressField.style.backgroundColor;
var targetAddressInvalidBackgroundColor = 'pink';

function isTargetAddressValid() {
  return !!targetAddressField.value.match(validTargetAddressRegex);
}

function validateTargetAddress() {
  if (isTargetAddressValid()) {
    targetAddressField.style.backgroundColor = targetAddressValidBackgroundColor;
  } else {
    targetAddressField.style.backgroundColor = targetAddressInvalidBackgroundColor;
  }
}

function validateForm() {
  return isTargetAddressValid();
}

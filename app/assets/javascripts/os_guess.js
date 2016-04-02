function osGuess() {
  var operatingSystemSelect = document.getElementById('operating_system');

  if (!operatingSystemSelect) { return; }

  var operatingSystem;

  if (navigator.platform.indexOf('Linux') != -1) {
    operatingSystem = 'linux';
  } else if (navigator.platform.indexOf('Mac') != -1) {
    operatingSystem = 'darwin';
  } else {
    operatingSystem = 'windows';
  }

  operatingSystemSelect.value = operatingSystem;
}

window.addEventListener('onload', osGuess());

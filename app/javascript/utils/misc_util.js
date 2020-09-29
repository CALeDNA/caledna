export const pluralize = (count, word) => {
  return count === 1 ? `1 ${word}` : `${count} ${word}s`;
};

// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math/random
export function getRandomInt(max) {
  return Math.floor(Math.random() * Math.floor(max));
}

export function getRandomInt(max) {
  return Math.floor(Math.random() * Math.floor(max));
}

export function randomColor() {
  return `hsla(${Math.floor(Math.random() * 360)}, 90%, 50%, 1)`;
}

function randomHslRange() {
  let rand = Math.floor(Math.random() * 360);
  return [
    `hsla(${rand}, 80%, 90%, 1)`,
    `hsla(${rand}, 80%, 70%, 1)`,
    `hsla(${rand}, 80%, 50%, 1)`,
    `hsla(${rand}, 80%, 30%, 1)`,
    `hsla(${rand}, 80%, 10%, 1)`,
  ];
}

export function randomColorRange() {
  let int = getRandomInt(5);
}

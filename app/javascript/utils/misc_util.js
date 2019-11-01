export const pluralize = (count, word) => {
  return count === 1 ? `1 ${word}` : `${count} ${word}s`;
};

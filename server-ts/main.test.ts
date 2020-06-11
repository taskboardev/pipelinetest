import { createItem, getItem } from './main';

const randomString = () => Math.random().toString(36).slice(-5);

test('create and get an item', async () => {
  const data = {
    id: randomString(),
    name: randomString(),
  };

  await createItem(data);

  const retrieved = await getItem(data.id);

  expect(retrieved).toEqual(data);
});

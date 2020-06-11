import { DynamoDB } from 'aws-sdk';

function getVariable(name: string): string {
  const val = process.env[name];

  if (!val) {
    console.log(`environment variable missing: "${name}"`);
    process.exit(1);
  }

  return val;
}

require('dotenv').config();
const region = getVariable('DYNAMO_REGION');
const endpoint = getVariable('DYNAMO_ENDPOINT');
const accessKeyId = getVariable('DYNAMO_ACCESS_KEY_ID');
const secretAccessKey = getVariable('DYNAMO_SECRET_ACCESS_KEY_ID');

const db = new DynamoDB({ region, endpoint, accessKeyId, secretAccessKey });

interface Item {
  id: string,
  name: string,
}

export const createItem = (item: Item) => {
  return db.putItem({
    TableName: 'dummy',
    Item: {
      id: { S: item.id },
      name: { S: item.name },
    },
  }).promise()
};

export const getItem = async (id: string) => {
  const retrieved = await db.getItem({
    TableName: 'dummy',
    Key: { id: { S: id } },
  }).promise();

  if (!retrieved || !retrieved.Item) {
    return undefined;
  }

  return {
    id: retrieved.Item['id'].S,
    name: retrieved.Item['name'].S,
  } as Item;
};

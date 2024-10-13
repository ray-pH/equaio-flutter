use equaio;

#[derive(Clone, Debug, Eq, PartialEq, Default)]
pub struct Address {
  pub path: Vec<i32>,
  pub sub: Option<i32>, // sub if for addressing subexpression in AssocTrain
}
impl From<equaio::expression::Address> for Address {
  fn from(address: equaio::expression::Address) -> Self {
    return Address {
      path: address.path.iter().map(|i| *i as i32).collect(),
      sub: address.sub.map(|i| i as i32),
    }
  }
}
impl From<Address> for equaio::expression::Address {
  fn from(address: Address) -> Self {
    return equaio::expression::Address {
      path: address.path.iter().map(|i| *i as usize).collect(),
      sub: address.sub.map(|i| i as usize),
    }
  }
}

#[derive(Debug, PartialEq, Default, Clone)]
pub enum BlockType {
  #[default]
  Symbol,
  HorizontalContainer,
  // VerticalContainer,
  FractionContainer,
}
impl From<equaio::block::BlockType> for BlockType {
  fn from(block_type: equaio::block::BlockType) -> Self {
    return match block_type {
      equaio::block::BlockType::Symbol => BlockType::Symbol,
      equaio::block::BlockType::HorizontalContainer => BlockType::HorizontalContainer,
      equaio::block::BlockType::FractionContainer => BlockType::FractionContainer,
    }
  }
}

pub struct Block {
  pub block_type: BlockType,
  pub address: Address,
  pub symbol: Option<String>,
  pub children: Option<Vec<Block>>,
}
impl From<equaio::block::Block> for Block {
  fn from(block: equaio::block::Block) -> Self {
    let children = block.children.map(|c| c.into_iter().map(|child| Block::from(child)).collect());
    return Block {
      block_type: block.block_type.into(),
      address: block.address.into(),
      symbol: block.symbol,
      children,
    }
  }
}
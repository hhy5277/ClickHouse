#pragma once

#include <string>
#include <Core/Block.h>
#include <DataStreams/IBlockInputStream.h>
#include <mysqlxx/PoolWithFailover.h>
#include <mysqlxx/Query.h>
#include "ExternalResultDescription.h"


namespace DB
{
/// Allows processing results of a MySQL query as a sequence of Blocks, simplifies chaining
class MySQLBlockInputStream final : public IBlockInputStream
{
public:
    MySQLBlockInputStream(
        const mysqlxx::PoolWithFailover::Entry & entry,
        const std::string & query_str,
        const Block & sample_block,
        const size_t max_block_size);

    String getName() const override { return "MySQL"; }

    Block getHeader() const override { return description.sample_block.cloneEmpty(); }

private:
    Block readImpl() override;

    mysqlxx::PoolWithFailover::Entry entry;
    mysqlxx::Query query;
    mysqlxx::UseQueryResult result;
    const size_t max_block_size;
    ExternalResultDescription description;
};

}

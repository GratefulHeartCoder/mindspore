/**
 * Copyright 2020 Huawei Technologies Co., Ltd
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef MINDSPORE_CCSRC_PS_PS_CACHE_GPU_GPU_PS_CACHE_H_
#define MINDSPORE_CCSRC_PS_PS_CACHE_GPU_GPU_PS_CACHE_H_

#include <cuda_runtime_api.h>
#include <memory>
#include "ps/ps_cache/ps_cache_basic.h"

namespace mindspore {
namespace ps {
namespace gpu {
class GPUPsCache : public PsCacheBasic {
 public:
  GPUPsCache() = default;
  ~GPUPsCache() override = default;
  void InitDevice(uint32_t device_id, const void *context) override;
  void *MallocMemory(size_t size) override;
  void RecordEvent() override;
  void SynchronizeEvent() override;
  void SynchronizeStream() override;
  void CopyHostMemToDevice(void *dst, void *src, size_t size) override;
  void CopyDeviceMemToHost(void *dst, void *src, size_t size) override;
  void HashSwapOut(void *hash_table_addr, void *swap_out_value_addr, void *swap_out_index_addr, size_t hash_table_size,
                   size_t embedding_size, size_t swap_out_size) override;
  void HashSwapIn(void *hash_table_addr, void *swap_in_value_addr, void *swap_in_index_addr, size_t hash_table_size,
                  size_t embedding_size, size_t swap_in_size) override;

 private:
  std::unique_ptr<cudaEvent_t> event_;
};
}  // namespace gpu
}  // namespace ps
}  // namespace mindspore
#endif  // MINDSPORE_CCSRC_PS_PS_CACHE_GPU_GPU_PS_CACHE_H_

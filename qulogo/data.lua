require('torch')
require('image')

local randomBatch = function(opt, config, pageIndex)
    local fileName = opt.d .. "/" .. pageIndex .. ".jpg"
    local fullImage = image.loadJPG(fileName)
   
    local batch = torch.Tensor(opt.batch_size, 3, config.inputHeight, config.inputWidth)
    local i = 1
    for i = 1, opt.batch_size do
        while true do
            local x = torch.random(config.imageWidth - config.inputWidth)
            local y = torch.random(config.imageHeight - config.inputHeight)
            
            local xx = math.min(x, config.logoX)
            local yy = math.min(y, config.logoY)
            local xx_ = math.max(x+config.inputWidth, config.logoX + config.logoWidth)
            local yy_ = math.max(x+config.inputHeight, config.logoY + config.logoHeight)
            if (    (xx_ - xx) > (config.logoWidth + config.inputWidth)
                or  (yy_ - yy) > (config.logoHeight + config.inputHeight) ) then
                batch[{i,{},{},{}}]:copy( fullImage[{{},{yy, yy + config.inputHeight - 1},{xx, xx + config.inputWidth -1}}] )   
                break;
            end
        end
    end

    batch = batch * 2 - 1;
    local maskPos = {{},{},
                       {config.maskTop, config.maskTop + config.maskHeight - 1},
                       {config.maskLeft, config.maskLeft + config.maskWidth - 1} }

    local centerBatch = batch[maskPos]:clone()
    batch[maskPos]:zero()
    
    return batch, centerBatch
end

d = {}
d.randomBatch = randomBatch
return d

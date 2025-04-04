function plot_ROIvoxels(betas,XYZcoord,beta_names,orientation)

if nargin < 4
    orientation = 'z';
end
if nargin < 3
    beta_names = [];
end
close all

% replace nans with 0.1
betas(isnan(betas)) = 0.1;

% coordinate details
mins = min(XYZcoord);
maxs = max(XYZcoord);

% loop through betas
for b = 1:size(betas,2)

    % fill in data
    mtx = zeros(maxs(1)-mins(1)+1,maxs(2)-mins(2)+1,maxs(3)-mins(3)+1);
    for v = 1:length(XYZcoord)
        mtx(XYZcoord(v,1)-mins(1)+1,XYZcoord(v,2)-mins(2)+1,XYZcoord(v,3)-mins(3)+1) = betas(v,b);
    end
    
    % N slices
    uzs = unique(XYZcoord(:,3));
    uxs = unique(XYZcoord(:,1));
    uys = unique(XYZcoord(:,2));
    
    % color scheme
    cmap = jet(251);
    cmap(126,:) = .8;
    
    % plot
    % z slices
    if strcmp(orientation,'z')
        for z = 1:size(mtx,3)
            figure()
            colormap(cmap)
            imagesc(flipud(fliplr(mtx(:,:,z)')));
            if ~isempty(beta_names)
                title([beta_names{b} '; z = ' int2str(uzs(z))])
            else
                
                % title(['z = ' int2str(uzs(z))]) comment for now
            end
            set(gca,'XTick',1:size(mtx,1),'XTicklabel',uxs)
            xlabel('x dir')
            set(gca,'YTick',1:size(mtx,2),'YTicklabel',flipud(uys))
            ylabel('y dir')
            colorbar
            caxis([-max(max(max(abs(squeeze(mtx(:,:,:)))))) max(max(max(abs(squeeze(mtx(:,:,:))))))])
        end
    elseif strcmp(orientation,'y')
        % y slices
        for y = 1:size(mtx,2)
            figure()
            colormap(cmap)
            imagesc(flipud(fliplr(squeeze(mtx(:,y,:))')));
            if ~isempty(beta_names)
                title([beta_names{b} '; y = ' int2str(uys(y))])
            else
                title(['y = ' int2str(uys(y))])
            end
            set(gca,'XTick',1:size(mtx,1),'XTicklabel',uxs)
            xlabel('x dir')
            set(gca,'YTick',1:size(mtx,3),'YTicklabel',flipud(uzs))
            ylabel('z dir')
            colorbar
            caxis([-max(max(max(abs(squeeze(mtx(:,:,:)))))) max(max(max(abs(squeeze(mtx(:,:,:))))))])
        end
    elseif strcmp(orientation,'x')
        % x slices
        for x = 1:size(mtx,1)
            figure()
            colormap(cmap)
            imagesc(flipud(fliplr(squeeze(mtx(x,:,:))')));
            if ~isempty(beta_names)
                title([beta_names{b} '; x = ' int2str(uxs(x))])
            else
                title(['x = ' int2str(uxs(x))])
            end
            set(gca,'XTick',1:size(mty,2),'XTicklabel',uys)
            xlabel('y dir')
            set(gca,'YTick',1:size(mtx,3),'YTicklabel',flipud(uzs))
            ylabel('z dir')
            colorbar
            caxis([-max(max(max(abs(squeeze(mtx(:,:,:)))))) max(max(max(abs(squeeze(mtx(:,:,:))))))])
        end
    end
end
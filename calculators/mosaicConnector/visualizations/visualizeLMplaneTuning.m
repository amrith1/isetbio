function visualizeLMplaneTuning(ax, xAxisData, yAxisData, xAxisDataFit, yAxisDataFit, targetRGC, markerSize, labelCells)
     
     if (markerSize < 100)
         lineWidth = 1.5;
     else
         lineWidth = 6.0;
     end
     
     hold(ax, 'on')
     
     maxData = max([max(abs(xAxisData)) max(abs(yAxisData))]);
     maxFit = max([max(abs(xAxisDataFit)) max(abs(yAxisDataFit))]);
     
     maxSpikeRate = maxData * 1.25; % max([max(maxData) max(maxFit)]);
     set(ax, 'YTick', (-1:0.5:1)*maxSpikeRate, 'YLim', [-maxSpikeRate maxSpikeRate]);
     set(ax, 'XTick', (-1:0.5:1)*maxSpikeRate, 'XLim', [-maxSpikeRate maxSpikeRate]);
     
     if (markerSize >= 100)
        for r = 4:-1:1
            radius = 0.25*r*maxSpikeRate;
            x = cosd(0:2:360);
            y = sind(0:2:360);
            
            %plot(ax,x*radius, y*radius, 'k-', 'Color', [0.5 0.5 0.5], 'LineWidth', 1.5);
            if (mod(r,2) == 0)
                faceColor = [0.92 0.92 0.92];
            else
                faceColor = [0.87 0.87 0.87];
            end
            edgeColor = faceColor*0.9;
            patchContour(ax, x*radius, y*radius, faceColor, edgeColor, 0.8, 0.7)
            
            plot(maxSpikeRate*[-1 1], [0 0], 'k-', 'Color', [0.8 0.8 0.8], 'LineWidth', 1.5);
            plot([0 0], maxSpikeRate*[-1 1], 'k-', 'Color', [0.8 0.8 0.8], 'LineWidth', 1.5);
        end

        plot( maxSpikeRate*[-1 1], [0 0], 'k-', 'Color', [0.5 0.5 0.5], 'LineWidth', 2.0);
        plot([0 0], maxSpikeRate*[-1 1], 'k-', 'Color', [0.5 0.5 0.5], 'LineWidth', 2.0);
        for k = 1:4
            plot(maxSpikeRate*[0.25 0.25]*k, maxSpikeRate*0.05*[-1 1], 'k-', 'Color', [0.5 0.5 0.5], 'LineWidth', 2.0);
        end
        for k = 1:4
            plot(-maxSpikeRate*[0.25 0.25]*k, maxSpikeRate*0.05*[-1 1], 'k-', 'Color', [0.5 0.5 0.5], 'LineWidth', 2.0);
        end
        for k = 1:4
            plot(maxSpikeRate*0.05*[-1 1], maxSpikeRate*[0.25 0.25]*k, 'k-', 'Color', [0.5 0.5 0.5], 'LineWidth', 2.0);
        end
        for k = 1:4
            plot(maxSpikeRate*0.05*[-1 1], -maxSpikeRate*[0.25 0.25]*k, 'k-', 'Color', [0.5 0.5 0.5], 'LineWidth', 2.0);
        end
        
        xlabel(ax, 'L-cone contrast');
        ylabel(ax, 'M-cone contrast');
        set(ax, 'XTickLabel', [-1.0:0.5:1.0], 'YTickLabel', -1:0.5:1, 'FontSize', 20, 'XColor', 'none', 'YColor', 'none');
     else
     plot( maxSpikeRate*[-1 1], [0 0], 'k-', 'Color', [0.5 0.5 0.5],  'LineWidth', 0.3);
        plot([0 0], maxSpikeRate*[-1 1], 'k-', 'Color', [0.5 0.5 0.5], 'LineWidth', 0.3);
        for k = 1:4
            plot(maxSpikeRate*[0.25 0.25]*k, maxSpikeRate*0.05*[-1 1], 'k-', 'Color', [0.5 0.5 0.5], 'LineWidth', 0.3);
        end
        for k = 1:4
            plot(-maxSpikeRate*[0.25 0.25]*k, maxSpikeRate*0.05*[-1 1], 'k-', 'Color', [0.5 0.5 0.5], 'LineWidth', 0.3);
        end
        for k = 1:4
            plot(maxSpikeRate*0.05*[-1 1], maxSpikeRate*[0.25 0.25]*k, 'k-', 'Color', [0.5 0.5 0.5], 'LineWidth', 0.3);
        end
        for k = 1:4
            plot(maxSpikeRate*0.05*[-1 1], -maxSpikeRate*[0.25 0.25]*k, 'k-', 'Color', [0.5 0.5 0.5], 'LineWidth', 0.3);
        end    
     end
     set(ax, 'XColor', 'none', 'YColor', 'none');
     
     if (all(isnan(xAxisDataFit)))
        xAxisData(end+1) = xAxisData(1);
        yAxisData(end+1) = yAxisData(1);
        line(ax, xAxisData , yAxisData , 'Color', [0.9 0.5 0.7], 'LineWidth', lineWidth);
     else
        line(ax, xAxisDataFit, yAxisDataFit, 'Color', [1 0.3 0.5]*0.6, 'LineWidth', lineWidth);
     end
     
     
     box(ax, 'off'); grid(ax, 'off');
     axis(ax, 'square')

     
     if (labelCells)
         
        xo = maxSpikeRate*0.85;
        yo = maxSpikeRate*0.85;
        text(ax, xo,yo, sprintf('%d', iRGC), 'FontSize',10);
        set(ax, 'XColor', 'none', 'YColor', 'none', 'LineWidth', 1.5);
     else
         set(ax, 'XTickLabel', {}, 'YTickLabel', {});
     end
     
     
     
     scatter(ax, xAxisData, yAxisData, markerSize, 'LineWidth', lineWidth, 'MarkerEdgeColor', [1 0.3 0.5]*0.6, 'MarkerFaceAlpha', 1, 'MarkerFaceColor', [1 0.3 0.5]);

end

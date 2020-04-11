%% clear
clc
clear

%% ���ñ���
g_node_list=[]; %����ڵ㼯��
g_link_list=[]; %���绡����
g_number_of_nodes=0; %����ڵ����
node_predecessor=[]; %ǰ��ڵ㼯��
node_label_cost=[]; %�����ǩ����
Max_label_cost=inf;%��ʼ�����ǩ

%% �������������ļ��������������粢��ʼ����ر���
%��ȡ����ڵ�����
df_node = csvread('node.csv',1,0);
g_number_of_nodes = size(df_node,1);
g_node_list = df_node(:,1);
node_label_cost=ones(g_number_of_nodes,g_number_of_nodes)*Max_label_cost;
node_predecessor=zeros(g_number_of_nodes,g_number_of_nodes);
for i = 1 : g_number_of_nodes
    for j = 1 : g_number_of_nodes
        if i==j
            node_label_cost(i,j)=0;
        end
    end
end

%��ȡ���绡����
df_link = csvread('road_link.csv',1,0);
g_link_list = df_link(:,2:3);
for i = 1 : size(df_link,1)
    Distance(df_link(i,2),df_link(i,3)) = df_link(i,4);
    node_label_cost(df_link(i,2),df_link(i,3))=df_link(i,4);
    node_predecessor(df_link(i,2),df_link(i,3))=df_link(i,2);
end

%% ���·����⣺ɨ�����绡�����ݼ���������������¾����ǩ
for k = 1 : g_number_of_nodes
    for arc_head =1:g_number_of_nodes
        for arc_tail =1:g_number_of_nodes
            if node_label_cost(arc_head,arc_tail)>node_label_cost(arc_head,k)+node_label_cost(k,arc_tail)
                    node_label_cost(arc_head,arc_tail)=node_label_cost(arc_head,k)+node_label_cost(k,arc_tail);
                    node_predecessor(arc_head,arc_tail)=node_predecessor(k,arc_tail);
            end
        end
    end
end

%% ����ǰ��ڵ��������·��
agent_id_column = [1:((g_number_of_nodes-1)*g_number_of_nodes)]';
o_zone_id_column = [];
d_zone_id_column = [];
path_column = {};
distance_column = [];
for from_node = 1 : g_number_of_nodes
    for to_node = 1 : g_number_of_nodes
        if from_node~=to_node
            if node_label_cost(from_node,to_node)==Max_label_cost
                path = "";
                distance = 99999;
                distance_column = [distance_column; 99999];
            else
                path=num2str(to_node);
                prior_point=node_predecessor(from_node,to_node);
                while prior_point~=from_node
                    path=strcat(';',path);
                    path=strcat(num2str(prior_point),path);
                    prior_point=node_predecessor(from_node,prior_point);
                end
                path=strcat(';',path);
                path=strcat(num2str(from_node),path);
                distance_column = [distance_column; node_label_cost(from_node,to_node)];
            end
            path_column=[path_column;path];
            o_zone_id_column=[o_zone_id_column;df_node(from_node,5)];
            d_zone_id_column=[d_zone_id_column;df_node(to_node,5)];
        end
    end
end

title = {'agent_id','o_zone_id','d_zone_id','node_sequence','distance'};
result_table=table(agent_id_column,o_zone_id_column,d_zone_id_column,path_column,distance_column,'VariableNames',title);
writetable(result_table, 'agent.csv','Delimiter',',','QuoteStrings',true)


